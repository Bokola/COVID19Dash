# Module UI

#' @title mode_about_ui and mod_about_server
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for `{shiny}`.
#'
#' @rdname mod_about
#'
#' @keywords internal
#' @export
#'
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

#' Module server
#'
#' @rdname mod_about
#' @export
#' @keywords internal
mod_about_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_about_ui("about_1")

## To be copied in the server
# mod_about_server("about_1")
