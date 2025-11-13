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
#' @import shinyWidgets
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

      # pickerInput(
      #   ns("level_select"),
      #   "Level:",
      #   choices = c("Global", "Continent", "Country", "US state"),
      #   selected = c("Country"),
      #   multiple = FALSE
      # ),
      selectInput(
        ns("level_select"),
        "Level:",
        choices = c("Global", "Continent", "Country", "US state"),
        selected = c("Country"),
        multiple = FALSE
      ),

      # pickerInput(
      #   ns("region_select"),
      #   "Country/Region:",
      #   choices = as.character(cv_today_reduced[order(-cv_today_reduced$cases), ]$country),
      #   options = list(`actions-box` = TRUE, `none-selected-text` = "Please make a selection!"),
      #   selected = as.character(cv_today_reduced[order(-cv_today_reduced$cases), ]$country)[1:10],
      #   multiple = TRUE
      # ),
      selectInput(
        ns("region_select"),
        "Country/Region:",
        choices = as.character(cv_today_reduced[order(-cv_today_reduced$cases), ]$country),
        # options = list(`actions-box` = TRUE, `none-selected-text` = "Please make a selection!"),
        selected = as.character(cv_today_reduced[order(-cv_today_reduced$cases), ]$country)[1:10],
        multiple = TRUE
      ),

      # pickerInput(
      #   ns("outcome_select"),
      #   "Outcome:",
      #   choices = c(
      #     "Deaths per million",
      #     "Cases per million",
      #     "Cases (total)",
      #     "Deaths (total)"
      #   ),
      #   selected = c("Deaths per million"),
      #   multiple = FALSE
      # ),
      selectInput(
        ns("outcome_select"),
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
      # pickerInput(
      #   ns("start_date"),
      #   "Plotting start date:",
      #   choices = c("Date", "Week of 100th confirmed case", "Week of 10th death"),
      #   options = list(`actions-box` = TRUE),
      #   selected = "Date",
      #   multiple = FALSE
      # ),
      selectInput(
        ns("start_date"),
        "Plotting start date:",
        choices = c("Date", "Week of 100th confirmed case", "Week of 10th death"),
        # options = list(`actions-box` = TRUE),
        selected = "Date",
        multiple = FALSE
      ),
      sliderInput(
        ns("minimum_date"),
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
        plotlyOutput(ns("plot_new"))),
        tabPanel("Cumulative (log10)", plotlyOutput(ns("plot_cum_log")))
    ))
  )
}

#'
#' @noRd
mod_region_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # create dataframe with selected countries
    country_reactive_db = reactive({
      if (input$level_select=="Global") {
        db = cv_cases_global
        db$region = db$global_level
      }
      if (input$level_select=="Continent") {
        db = cv_cases_continent
        db$region = db$continent
      }
      if (input$level_select=="Country") {
        db = cv_cases
        db$region = db$country
      }
      if (input$level_select=="US state") {
        db = cv_states
        db$region = db$state
      }

      if (input$outcome_select=="Cases (total)") {
        db$outcome = db$cases
        db$new_outcome = db$new_cases
      }

      if (input$outcome_select=="Deaths (total)") {
        db$outcome = db$deaths
        db$new_outcome = db$new_deaths
      }

      if (input$outcome_select=="Cases per million") {
        db$outcome = db$cases_per_million
        db$new_outcome = db$new_cases_per_million
      }

      if (input$outcome_select=="Deaths per million") {
        db$outcome = db$deaths_per_million
        db$new_outcome = db$new_deaths_per_million
      }

      db %>% filter(region %in% input$region_select)
    })
    # country-specific plots
    output$plot_cum <- renderPlotly({
      country_cases_cumulative(country_reactive_db(),
                               start_point = input$start_date,
                               input$minimum_date)
    })

    output$plot_new <- renderPlotly({
      country_cases_plot(country_reactive_db(),
                         start_point = input$start_date,
                         input$minimum_date)
    })

    output$plot_cum_log <- renderPlotly({
      country_cases_cumulative_log(country_reactive_db(),
                                   start_point = input$start_date,
                                   input$minimum_date)
    })

  })
}
