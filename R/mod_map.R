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
#' @export
mod_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    leafletOutput(ns("mymap"), width = "100%", height = "80vh"),
    absolutePanel(
      id = ns("controls"),
      class = "panel panel-default",
      top = 75,
      left = 55,
      width = 250,
      fixed = TRUE,
      draggable = TRUE,
      span(tags$i(
        h6("Reported cases vary by country testing capacity.")
      ), style = "color:#045a8d"),
      h3(textOutput(ns(
        "reactive_case_count"
      )), align = "right"),
      h4(textOutput(ns(
        "reactive_death_count"
      )), align = "right"),
      h6(textOutput(ns(
        "clean_date_reactive"
      )), align = "right"),
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
  # covid tab
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # covid tab
    formatted_date = reactive({
      format(as.Date(input$plot_date, format = "%d %b %y"), "%Y-%m-%d")
    })

    output$clean_date_reactive <- renderText({
      format(as.POSIXct(formatted_date()), "%d %B %Y")
    })

    reactive_db = reactive({
      cv_cases %>% filter(date == formatted_date())
    })

    reactive_db_last7d = reactive({
      cv_cases %>% filter(date == formatted_date() & new_cases > 0)
    })

    reactive_db_large = reactive({
      large_countries = reactive_db() %>% filter(alpha3 %in% worldcountry$ADM0_A3)
      #large_countries = reactive %>% filter(alpha3 %in% worldcountry$ADM0_A3)
      worldcountry_subset = worldcountry[worldcountry$ADM0_A3 %in% large_countries$alpha3, ]
      large_countries = large_countries[match(worldcountry_subset$ADM0_A3, large_countries$alpha3), ]
      large_countries
    })

    reactive_db_large_last7d = reactive({
      large_countries = reactive_db_last7d() %>% filter(alpha3 %in% worldcountry$ADM0_A3)
      large_countries = large_countries[order(large_countries$alpha3), ]
      large_countries
    })

    reactive_polygons = reactive({
      worldcountry[worldcountry$ADM0_A3 %in% reactive_db_large()$alpha3, ]
    })

    reactive_polygons_last7d = reactive({
      worldcountry[worldcountry$ADM0_A3 %in% reactive_db_large_last7d()$alpha3, ]
    })

    output$reactive_case_count <- renderText({
      paste0(prettyNum(sum(reactive_db()$cases), big.mark = ","), " cases")
    })

    output$reactive_death_count <- renderText({
      paste0(prettyNum(sum(reactive_db()$deaths), big.mark = ","), " deaths")
    })

    output$reactive_country_count <- renderText({
      paste0(nrow(
        subset(reactive_db(), country != "Diamond Princess Cruise Ship")
      ), " countries/regions affected")
    })

    output$reactive_new_cases_7d <- renderText({
      paste0(round((
        cv_aggregated %>% filter(date == formatted_date() &
                                   region == "Global")
      )$new / 7, 0), " 7-day average")
    })

    output$mymap <- renderLeaflet({
      basemap
    })

    observeEvent(input$plot_date, {
      leafletProxy("mymap") %>%
        clearMarkers() %>%
        clearShapes() %>%

        addCircleMarkers(
          data = reactive_db(),
          lat = ~ latitude,
          lng = ~ longitude,
          weight = 1,
          radius = ~ (cases)^(1 / 5.5),
          fillOpacity = 0.1,
          color = covid_col,
          group = "2019-COVID (cumulative)",
          label = sprintf(
            "<strong>%s (cumulative)</strong><br/>Confirmed cases: %g<br/>Deaths: %d<br/>Cases per million: %g<br/>Deaths per million: %g",
            reactive_db()$country,
            reactive_db()$cases,
            reactive_db()$deaths,
            reactive_db()$cases_per_million,
            reactive_db()$deaths_per_million
          ) %>% lapply(htmltools::HTML),
          labelOptions = labelOptions(
            style = list(
              "font-weight" = "normal",
              padding = "3px 8px",
              "color" = covid_col
            ),
            textsize = "15px",
            direction = "auto"
          )
        ) %>%

        addPolygons(
          data = reactive_polygons(),
          stroke = FALSE,
          smoothFactor = 0.1,
          fillOpacity = 0.15,
          fillColor = ~ cv_pal(reactive_db_large()$deaths_per_million)
        ) %>%

        addCircleMarkers(
          data = reactive_db_last7d(),
          lat = ~ latitude,
          lng = ~ longitude,
          weight = 1,
          radius = ~ (new_cases)^(1 / 5.5),
          fillOpacity = 0.1,
          color = covid_col,
          group = "2019-COVID (new)",
          label = sprintf(
            "<strong>%s (7-day average)</strong><br/>Confirmed cases: %g<br/>Deaths: %d<br/>Cases per million: %g<br/>Deaths per million: %g",
            reactive_db_last7d()$country,
            round(reactive_db_last7d()$new_cases / 7, 0),
            round(reactive_db_last7d()$new_deaths / 7, 0),
            round(reactive_db_last7d()$new_cases_per_million / 7, 1),
            round(reactive_db_last7d()$new_deaths_per_million / 7, 1)
          ) %>% lapply(htmltools::HTML),
          labelOptions = labelOptions(
            style = list(
              "font-weight" = "normal",
              padding = "3px 8px",
              "color" = covid_col
            ),
            textsize = "15px",
            direction = "auto"
          )
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
