#' data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
mod_data_ui <- function(id) {
  ns <- NS(id)
  tagList(
    numericInput(ns("maxrows"), "Rows to show", 25),
    verbatimTextOutput(ns("rawtable")),
    downloadButton(ns("downloadCsv"), "Download as CSV")
  )
}



#' data Server Functions
#'
#' @noRd
mod_data_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$downloadCsv <- downloadHandler(
      filename = function() {
        paste("COVID_data_", cv_today$date[1], ".csv", sep = "")
      },
      content = function(file) {
        cv_cases_sub = cv_cases %>% select(
          c(
            country,
            date,
            cases,
            new_cases,
            deaths,
            new_deaths,
            cases_per_million,
            new_cases_per_million,
            deaths_per_million,
            new_deaths_per_million
          )
        )
        names(cv_cases_sub) = c(
          "country",
          "date",
          "cumulative_cases",
          "new_cases_past_week",
          "cumulative_deaths",
          "new_deaths_past_week",
          "cumulative_cases_per_million",
          "new_cases_per_million_past_week",
          "cumulative_deaths_per_million",
          "new_deaths_per_million_past_week"
        )
        write.csv(cv_cases_sub, file)
      }
    )

    output$rawtable <- renderPrint({
      cv_cases_sub = cv_cases %>% select(
        c(
          country,
          date,
          cases,
          new_cases,
          deaths,
          new_deaths,
          cases_per_million,
          new_cases_per_million,
          deaths_per_million,
          new_deaths_per_million
        )
      )
      names(cv_cases_sub) = c(
        "country",
        "date",
        "cumulative_cases",
        "new_cases_past_week",
        "cumulative_deaths",
        "new_deaths_past_week",
        "cumulative_cases_per_million",
        "new_cases_per_million_past_week",
        "cumulative_deaths_per_million",
        "new_deaths_per_million_past_week"
      )
      orig <- options(width = 1000)
      print(tail(cv_cases_sub, input$maxrows), row.names = FALSE)
      options(orig)
    })

  })
}

## To be copied in the UI
# mod_data_ui("data_1")

## To be copied in the server
# mod_data_server("data_1")
