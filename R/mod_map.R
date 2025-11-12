#' covid_mapper UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
#' @import leaflet
#' @import dplyr
mod_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    leafletOutput(ns("mymap"), width = "100%", height = "80vh"),
    absolutePanel(
      id = ns("controls"),
      class = "panel panel-default",
      top = 75, left = 55, width = 250, fixed = TRUE, draggable = TRUE,
      span(tags$i(h6("Reported cases vary by country testing capacity.")), style = "color:#045a8d"),
      h3(textOutput(ns("reactive_case_count")), align = "right"),
      h4(textOutput(ns("reactive_death_count")), align = "right"),
      h6(textOutput(ns("clean_date_reactive")), align = "right"),
      plotOutput(ns("epi_curve"), height = "130px", width = "100%"),
      plotOutput(ns("cumulative_plot"), height = "130px", width = "100%"),
      sliderTextInput(
        ns("plot_date"),
        label = h5("Select mapping date"),
        choices = format(unique(cv_cases$date), "%d %b %y"),
        selected = format(current_date, "%d %b %y"),
        grid = FALSE,
        animate = animationOptions(interval = 3000, loop = FALSE)
      )
    )
  )
}

#' covid_mapper Server Function
#' @noRd
mod_map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    formatted_date <- reactive({
      as.Date(input$plot_date, format = "%d %b %y")
    })

    reactive_db <- reactive({
      cv_cases %>% filter(date == formatted_date())
    })

    output$reactive_case_count <- renderText({
      paste0(prettyNum(sum(reactive_db()$cases), big.mark = ","), " cases")
    })

    output$reactive_death_count <- renderText({
      paste0(prettyNum(sum(reactive_db()$deaths), big.mark = ","), " deaths")
    })

    output$clean_date_reactive <- renderText({
      format(formatted_date(), "%d %B %Y")
    })

    output$mymap <- renderLeaflet({
      leaflet(worldcountry) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        addCircleMarkers(
          data = reactive_db(),
          lng = ~longitude,
          lat = ~latitude,
          color = covid_col,
          radius = ~ (cases)^(1/5.5),
          label = ~paste0(country, ": ", prettyNum(cases, big.mark=","), " cases")
        )
    })

    output$cumulative_plot <- renderPlot({
      cumulative_plot(cv_aggregated, formatted_date())
    })

    output$epi_curve <- renderPlot({
      new_cases_plot(cv_aggregated, formatted_date())
    })
  })
}
