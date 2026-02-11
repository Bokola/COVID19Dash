#' application user interface
#'
#' @param request internal parameter for shiny
#'
#' @noRd
#' @import shiny
#' @import golem
#' @import shinyWidgets
#' @import shinythemes
#' @import plotly
#' @import htmltools
#' @importFrom plotly plotlyOutput
#' @importFrom leaflet leafletOutput
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    tagList(
      tags$head(
        # use app_sys to find the internal css file correctly
        tags$style(includeCSS(app_sys("app/www/custom.css")))
      ),

      fluidPage(
        theme = shinythemes::shinytheme("flatly"),
        titlePanel("COVID-19 Tracker"),

        fluidRow(
          column(2, actionButton("tab_mapper", "Mapper", class = "btn-primary w-100")),
          column(2, actionButton("tab_region", "Region Plots", class = "btn-primary w-100")),
          column(2, actionButton("tab_data", "Data", class = "btn-primary w-100")),
          column(2, actionButton("tab_predict", "Prediction Model", class = "btn-primary w-100")),
          column(2, actionButton("tab_about", "About", class = "btn-primary w-100"))
        ),

        hr(),
        uiOutput("main_ui")
      )
    )
  )
}

#' add external resources
#'
#' @noRd
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @importFrom shiny tags
golem_add_external_resources <- function() {
  # explicit namespace calls to prevent find function errors
  golem::add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    golem::favicon(),
    golem::bundle_resources(
      path = app_sys("app/www"),
      app_title = "COVID-19 tracker"
    ),

    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css",
      integrity = "sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T",
      crossorigin = "anonymous"
    ),
    tags$script(
      src = "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js",
      integrity = "sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM",
      crossorigin = "anonymous"
    ),
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "www/custom.css"
    )
  )
}
