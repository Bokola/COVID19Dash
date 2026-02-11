#' module for epidemic forecasting
#'
#' @param id internal
#' @param cv_states data
#'
#' @noRd
#' @export
#' @importFrom shiny NS tagList sidebarLayout sidebarPanel mainPanel h4 p actionButton hr uiOutput textOutput tabsetPanel tabPanel icon tags HTML downloadButton verbatimTextOutput h5 br tableOutput downloadHandler
#' @importFrom plotly plotlyOutput renderPlotly
#' @importFrom DT DTOutput renderDT
#' @import dplyr
#' @import xgboost
#' @import deSolve
#' @import future
#' @import promises
#' @import zoo
#' @import purrr
mod_prediction_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$script(HTML(paste0("
      Shiny.addCustomMessageHandler('download_plotly_png', function(message) {
        var gd = document.getElementById(message.id);
        Plotly.downloadImage(gd, {
          format: 'png',
          filename: message.filename,
          height: 600,
          width: 1000
        });
      });
    "))),
    sidebarLayout(
      sidebarPanel(
        h4("epidemiological forecaster"),
        p("comparing machine learning xgboost with mechanistic sir modeling"),
        actionButton(ns("run_btn"), "run global analytics",
                     class = "btn-primary btn-block", icon = icon("play")),
        hr(),
        uiOutput(ns("picker_ui")),
        hr(),
        h5("data exports"),
        downloadButton(ns("dl_global_csv"), "all metrics (csv)", class = "btn-info btn-block"),
        br(),
        actionButton(ns("dl_plot_img_js"), "download plot (png)", class = "btn-info btn-block"),
        br(),
        downloadButton(ns("dl_plot_data"), "plot data (csv)", class = "btn-info btn-block"),
        br(),
        downloadButton(ns("dl_params_csv"), "state params (csv)", class = "btn-info btn-block"),
        hr(),
        h5("worker status"),
        verbatimTextOutput(ns("status_text"))
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("global metrics",
                   br(),
                   DT::DTOutput(ns("global_summary"))),
          tabPanel("projection comparison",
                   br(),
                   plotly::plotlyOutput(ns("plot_comp"), height = "500px")),
          tabPanel("model parameters",
                   br(),
                   tableOutput(ns("rmse_table")))
        )
      )
    )
  )
}

#' @noRd
#' @export
mod_prediction_server <- function(id, cv_states) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    store  <- reactiveValues(results = NULL)
    status <- reactiveVal("system idle click run to begin")

    observeEvent(input$run_btn, {
      status("processing global data please wait")
      formatted_data <- cv_states %>%
        mutate(
          date = as.Date(date),
          new_cases = as.numeric(new_cases),
          pop = as.numeric(population)
        ) %>%
        filter(!is.na(date), !is.na(new_cases), pop > 0) %>%
        group_by(state) %>%
        arrange(date) %>%
        mutate(
          time_index = as.numeric(date - min(date)),
          case_ratio = new_cases / pop,
          roll_7  = zoo::rollmean(lag(new_cases, 1), 7, fill = 0, align = "right"),
          roll_14 = zoo::rollmean(lag(new_cases, 1), 14, fill = 0, align = "right"),
          roll_30 = zoo::rollmean(lag(new_cases, 1), 30, fill = 0, align = "right")
        ) %>%
        ungroup()

      p <- future_promise({
        library(xgboost)
        library(deSolve)
        run_engine <- function(s_name, s_df) {
          tryCatch({
            if (nrow(s_df) < 60) return(NULL)
            feats <- c("latitude", "longitude", "time_index", "roll_7", "roll_14", "roll_30")
            x <- as.matrix(s_df[, feats])
            y <- s_df$new_cases
            dtrain <- xgboost::xgb.DMatrix(data = x, label = y)
            model <- xgboost::xgb.train(
              params = list(objective = "reg:squarederror", learning_rate = 0.1, max_depth = 5, nthread = 1, verbosity = 0),
              data = dtrain, nrounds = 25
            )
            raw_model <- xgboost::xgb.save.raw(model)
            m_rmse <- sqrt(mean((y - predict(model, dtrain))^2, na.rm = TRUE))
            rm(model, dtrain); gc()
            y0 <- c(S = 0.999, I = max(s_df$case_ratio[1], 1e-5), R = 0)
            fit <- optim(
              par = c(beta = 0.25, gamma = 0.1),
              fn = function(p) {
                out <- try(deSolve::ode(y = y0, times = s_df$time_index, func = function(t,v,p) {
                  list(c(-p[1]*v[1]*v[2], p[1]*v[1]*v[2] - p[2]*v[2], p[2]*v[2]))
                }, parms = p), silent = TRUE)
                if (inherits(out, "try-error") || any(is.na(out))) return(1e12)
                sum((out[,3] - s_df$case_ratio)^2, na.rm = TRUE)
              },
              method = "L-BFGS-B", lower = c(0.01, 0.01), upper = c(2.0, 1.0)
            )
            list(state = s_name, xgb_raw = raw_model, xgb_rmse = m_rmse, sir_pars = fit$par, data_full = s_df, x_mat = x)
          }, error = function(e) NULL)
        }
        states_list <- unique(formatted_data$state)
        res <- lapply(states_list, function(sn) run_engine(sn, formatted_data[formatted_data$state == sn, ]))
        purrr::compact(res)
      }, seed = TRUE)

      then(p, onFulfilled = function(val) {
        store$results <- val
        status(paste("success analyzed", length(val), "regions"))
      })
      NULL
    })

    selected_res <- reactive({
      req(store$results, input$state_sel)
      res <- purrr::detect(store$results, ~ .x$state == input$state_sel)
      if (!is.null(res) && !is.null(res$xgb_raw)) {
        res$xgb_obj <- xgboost::xgb.load.raw(res$xgb_raw)
      }
      res
    })

    output$plot_comp <- plotly::renderPlotly({
      req(selected_res())
      res <- selected_res()
      df <- res$data_full
      dtest <- xgboost::xgb.DMatrix(res$x_mat)
      ml_preds <- predict(res$xgb_obj, dtest)
      sir_out <- as.data.frame(deSolve::ode(
        y = c(S = 0.999, I = max(df$case_ratio[1], 1e-5), R = 0),
        times = df$time_index,
        func = function(t, v, p) list(c(-p[1]*v[1]*v[2], p[1]*v[1]*v[2] - p[2]*v[2], p[2]*v[2])),
        parms = res$sir_pars
      ))
      plotly::plot_ly(df, x = ~date) %>%
        plotly::add_markers(y = ~new_cases, name = "reported", opacity = 0.4) %>%
        plotly::add_lines(y = ml_preds, name = "xgboost") %>%
        plotly::add_lines(y = sir_out[,3] * df$pop[1], name = "sir", line = list(dash = "dot")) %>%
        plotly::layout(title = paste("projections for", res$state))
    })

    observeEvent(input$dl_plot_img_js, {
      session$sendCustomMessage("download_plotly_png", list(
        id = ns("plot_comp"),
        filename = paste0("plot_", input$state_sel, ".png")
      ))
    })

    output$status_text <- renderText(status())

    output$picker_ui <- renderUI({
      req(store$results)
      states_names <- sapply(store$results, `[[`, "state")
      selectInput(ns("state_sel"), "focus on region", choices = sort(states_names))
    })

    output$global_summary <- DT::renderDT({
      req(store$results)
      df_sum <- do.call(rbind, lapply(store$results, function(x) {
        data.frame(region = x$state, xgb_rmse = round(x$xgb_rmse, 2), r0 = round(x$sir_pars[1] / x$sir_pars[2], 2))
      }))
      DT::datatable(df_sum)
    })

    output$rmse_table <- renderTable({
      req(selected_res())
      res <- selected_res()
      data.frame(
        metric = c("ml rmse total cases", "sir beta transmission", "sir gamma recovery", "basic reproduction number r0"),
        value  = c(as.character(round(res$xgb_rmse, 2)), as.character(round(res$sir_pars[1], 4)),
                   as.character(round(res$sir_pars[2], 4)), as.character(round(res$sir_pars[1] / res$sir_pars[2], 2)))
      )
    }, striped = TRUE, bordered = TRUE)

    output$dl_global_csv <- downloadHandler(
      filename = function() { paste0("global_metrics_", Sys.Date(), ".csv") },
      content = function(file) {
        df_dl <- do.call(rbind, lapply(store$results, function(x) {
          data.frame(region = x$state, xgb_rmse = x$xgb_rmse, r0 = x$sir_pars[1]/x$sir_pars[2])
        }))
        write.csv(df_dl, file, row.names = FALSE)
      }
    )

    output$dl_plot_data <- downloadHandler(
      filename = function() { paste0("projection_data_", input$state_sel, ".csv") },
      content = function(file) { write.csv(selected_res()$data_full, file, row.names = FALSE) }
    )

    output$dl_params_csv <- downloadHandler(
      filename = function() { paste0("params_", input$state_sel, ".csv") },
      content = function(file) {
        res_p <- selected_res()
        write.csv(data.frame(region = res_p$state, beta = res_p$sir_pars[1], gamma = res_p$sir_pars[2]), file, row.names = FALSE)
      }
    )
  })
}
