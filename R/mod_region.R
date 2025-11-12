#' region_plots UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
#' @import dplyr
mod_region_ui <- function(id) {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(
      span(tags$i(
        h6(
          "Reported cases are subject to significant variation in testing policy and capacity between countries."
        )
      ), style = "color:#045a8d"),
      span(tags$i(
        h6(
          "Occasional anomalies (e.g. spikes in daily case counts) are generally caused by changes in case definitions."
        )
      ), style = "color:#045a8d"),

      pickerInput(
        "level_select",
        "Level:",
        choices = c("Global", "Continent", "Country", "US state"),
        selected = c("Country"),
        multiple = FALSE
      ),

      pickerInput(
        "region_select",
        "Country/Region:",
        choices = as.character(cv_today_reduced[order(-cv_today_reduced$cases), ]$country),
        options = list(`actions-box` = TRUE, `none-selected-text` = "Please make a selection!"),
        selected = as.character(cv_today_reduced[order(-cv_today_reduced$cases), ]$country)[1:10],
        multiple = TRUE
      ),

      pickerInput(
        "outcome_select",
        "Outcome:",
        choices = c(
          "Deaths per million",
          "Cases per million",
          "Cases (total)",
          "Deaths (total)"
        ),
        selected = c("Deaths per million"),
        multiple = FALSE
      ),
      pickerInput(
        "start_date",
        "Plotting start date:",
        choices = c("Date", "Week of 100th confirmed case", "Week of 10th death"),
        options = list(`actions-box` = TRUE),
        selected = "Date",
        multiple = FALSE
      ),
      sliderInput(
        "minimum_date",
        "Minimum date:",
        min = as.Date(cv_min_date, "%Y-%m-%d"),
        max = as.Date(current_date, "%Y-%m-%d"),
        value = as.Date(cv_min_date),
        timeFormat = "%d %b"
      ),
      "Select outcome, regions, and plotting start date from drop-down menues to update plots. Countries with at least 1000 confirmed cases are included."

    ),
    mainPanel(tabsetPanel(
      tabPanel("Cumulative", plotlyOutput(ns("plot_cum"))),
      tabPanel(
        "New",
        plotlyOutput(ns("plot_new")),
        tabPanel(
          "Cumulative (log10)",
          plotlyOutput("plot_cum_log")
        )
      )
    ))
  )
}

#'
#' @noRd
mod_region_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    filtered_data <- reactive({
      cv_cases %>%
        filter(country %in% input$region_select, date >= input$minimum_date)
    })

    output$plot_cum <- renderPlotly({
      p <- ggplot(filtered_data(), aes(x = date, y = cases, color = country)) +
        geom_line(linewidth = 1) +
        theme_minimal() +
        labs(y = paste("Cumulative", input$outcome_select))
      ggplotly(p)
    })

    output$plot_new <- renderPlotly({
      p <- ggplot(filtered_data(), aes(x = date, y = new_cases, color = country)) +
        geom_line(linewidth = 1) +
        theme_minimal() +
        labs(y = paste("New", input$outcome_select))
      ggplotly(p)
    })
  })
}
