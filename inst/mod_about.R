# mod_about.R ----

mod_about_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      tags$h4("About This Site"),
      "This interactive tracker visualizes COVID-19 data worldwide.",
      tags$br(), tags$br(),
      "Data sources: ",
      tags$a(href = "https://github.com/CSSEGISandData/COVID-19", "Johns Hopkins University CSSE"),
      tags$br(),
      "Code adapted from open-source COVID-19 dashboards.",
      tags$br(), tags$br(),
      tags$img(src = "vac_dark.png", width = "150px"),
      tags$img(src = "lshtm_dark.png", width = "150px")
    )
  )
}

mod_about_server <- function(id) {
  moduleServer(id, function(input, output, session) {})
}
