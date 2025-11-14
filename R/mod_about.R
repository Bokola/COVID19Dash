# Module UI

#' @title mode_about_ui and mod_about_server
#'
#' @description mod_about_ui() function
#'
#' @param id Internal parameters for \code{shiny}.
#'

#'
#' @keywords internal

#' @usage mod_about_ui(id)
#' @export
#' @importFrom shiny NS tagList includeMarkdown
mod_about_ui <- function(id) {
  ns <- NS(id)
  tagList(
    col_6(
      includeMarkdown(
        system.file("app/www/about.md", package = "COVID19Dash")
      )
    ),
    col_6(
      includeMarkdown(
        system.file("app/www/tech.md", package = "COVID19Dash")
      )
    )
  )
}

#' @title mod_about_server
#'
#'@description mod_about_server() function

#' @param id internal shiny function
#' @usage mod_about_server(id)
#' @keywords internal
#' @export
mod_about_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_about_ui("about_1")

## To be copied in the server
# mod_about_server("about_1")
