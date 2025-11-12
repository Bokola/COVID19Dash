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

    output$rawtable <- renderPrint({
      data <- cv_cases %>%
        select(country, date, cases, deaths, new_cases, new_deaths)
      print(tail(data, input$maxrows), row.names = FALSE)
    })

    output$downloadCsv <- downloadHandler(
      filename = function() paste0("COVID_data_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(cv_cases, file, row.names = FALSE)
      }
    )
  })
}

## To be copied in the UI
# mod_data_ui("data_1")

## To be copied in the server
# mod_data_server("data_1")
