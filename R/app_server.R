#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  current_tab <- reactiveVal("mapper")

  observeEvent(input$tab_mapper, current_tab("mapper"))
  observeEvent(input$tab_region, current_tab("region"))
  observeEvent(input$tab_data, current_tab("data"))
  observeEvent(input$tab_about, current_tab("about"))

  output$main_ui <- renderUI({
    switch(current_tab(),
           "mapper" = mod_map_ui("mapper"),
           "region" = mod_region_ui("region"),
           "data"   = mod_data_ui("data"),
           "about"  = mod_about_ui("about"))
  })

  mod_map_server("mapper")
  mod_region_server("region")
  mod_data_server("data")
  mod_about_server("about")
}
