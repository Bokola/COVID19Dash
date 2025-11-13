#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import golem
#' @import shinyWidgets
#' @import shinythemes
#' @import plotly
#' @import htmltools
#' @importFrom plotly plotlyOutput
#' @importFrom leaflet leafletOutput

#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    tagList(
      # tags$head(includeHTML(
      #   system.file("inst/app/www/gtag.html", package = "COVID19Dash")
      # )),
      tags$head(includeCSS(
        system.file("app/www/custom.css", package = "COVID19Dash")
      )),

      fluidPage(
        theme = shinytheme("flatly"),
        titlePanel("COVID-19 Tracker"),

        fluidRow(
          column(3, actionButton("tab_mapper", "Mapper", class = "btn-primary w-100")),
          column(3, actionButton("tab_region", "Region Plots", class = "btn-primary w-100")),
          column(3, actionButton("tab_data", "Data", class = "btn-primary w-100")),
          column(3, actionButton("tab_about", "About", class = "btn-primary w-100"))
        ),

        hr(),
        uiOutput("main_ui")
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "COVID-19 tracker"
    ),

    # includeCSS("www/custom.css"),

    # Add here other external resources
    # if you have a custom.css in the inst/app/www
    # for example, you can add shinyalert::useShinyalert()
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css",
      integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T",
      crossorigin="anonymous"
    ),
    tags$script(
      src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js",
      integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM",
      crossorigin="anonymous"
    )
    ,tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "www/custom.css"
    )
    ,tags$script(src="www/gtag.html")
  )
}
