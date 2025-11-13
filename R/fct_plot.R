### MAP FUNCTIONS ###



#' @title cls colorbrewer object
#'
#' @param df1 dataframe
#' @param df2 dataframe
#' @param df3 dataframe
#'
#' @importFrom RColorBrewer brewer.pal
#'
#' @export
#'
#' @usage cls(df1, df2, df3)
cls <- function(df1 = cv_cases, df2 = cv_cases_continent, df3 = cv_states ){
  cls <- rep(
    c(
      RColorBrewer::brewer.pal(8, "Dark2"),
      RColorBrewer::brewer.pal(10, "Paired"),
      RColorBrewer::brewer.pal(12, "Set3"),
      RColorBrewer::brewer.pal(8, "Set2"),
      RColorBrewer::brewer.pal(9, "Set1"),
      RColorBrewer::brewer.pal(8, "Accent"),
      RColorBrewer::brewer.pal(9, "Pastel1"),
      RColorBrewer::brewer.pal(8, "Pastel2")
    ),
    4
  )
  cls_names <- c(as.character(unique(df1[,'country'])),
                 as.character(unique(df2[,'continent'])),
                 as.character(unique(df3[,'state'])),
                 "Global")
  country_cols <- cls[1:length(cls_names)]
  names(country_cols) <- cls_names

  country_cols
}




#' @title cumulatve_plot
#' @description a function to plot cumulative cases of covid
#' @param cv_aggregated dataframe
#' @param plot_date Date variable
#' @import ggplot2
#'
#' @usage cumulative_plot(cv_aggregated, plot_date)
#' @export

# function to plot cumulative COVID cases by date
cumulative_plot <- function(cv_aggregated, plot_date) {
  plot_df = subset(cv_aggregated, date <= plot_date)
  g1 = ggplot2::ggplot(plot_df, aes(x = date, y = cases, color = region)) + geom_line() + geom_point(size = 1, alpha = 0.8) +
    ylab("Cumulative cases") +  xlab("Date") + theme_bw() +
    scale_colour_manual(values = c(covid_col)) +
    scale_y_continuous(
      labels = function(l) {
        trans = l / 1000000
        paste0(trans, "M")
      }
    ) +
    theme(
      legend.title = element_blank(),
      legend.position = "",
      plot.title = element_text(size = 10),
      plot.margin = margin(5, 12, 5, 5)
    )
  g1
}

#' @title new_cases_plot
#' @description a function to plot new cases of covid
#' @param cv_aggregated dataframe
#' @param plot_date Date variable
#' @import ggplot2
#'
#' @usage new_cases_plot(cv_aggregated, plot_date)
#' @export
new_cases_plot <- function(cv_aggregated, plot_date) {
  plot_df_new = subset(cv_aggregated, date <= plot_date)
  g1 = ggplot2::ggplot(plot_df_new, aes(x = date, y = new, colour = region)) + geom_line() + geom_point(size = 1, alpha = 0.8) +
    # geom_bar(position="stack", stat="identity") +
    ylab("New cases (weekly)") + xlab("Date") + theme_bw() +
    scale_colour_manual(values = c(covid_col)) +
    scale_y_continuous(
      labels = function(l) {
        trans = l / 1000000
        paste0(trans, "M")
      }
    ) +
    theme(
      legend.title = element_blank(),
      legend.position = "",
      plot.title = element_text(size = 10),
      plot.margin = margin(5, 12, 5, 5)
    )
  g1
}


#' @title country_cases_plot
#' @description a function to plot cases of covid by region
#' @param cv_cases dataframe
#' @param start_point character string indicating point of origin
#' @param plot_start_date Date variable
#' @import ggplot2
#' @importFrom plotly ggplotly
#'
#' @usage country_cases_plot(cv_cases, start_point, plot_start_date)
#' @export
country_cases_plot <- function(cv_cases,
                               start_point = c("Date", "Week of 100th confirmed case", "Week of 10th death"),
                               plot_start_date) {
  if (start_point == "Date") {
    g = ggplot(cv_cases,
               aes(
                 x = date,
                 y = new_outcome,
                 fill = region,
                 group = 1,
                 text = paste0(format(date, "%d %B %Y"), "\n", region, ": ", new_outcome)
               )) +
      xlim(c(plot_start_date, (current_date + 5))) + xlab("Date")
  }

  if (start_point == "Week of 100th confirmed case") {
    cv_cases = subset(cv_cases, weeks_since_case100 > 0)
    g = ggplot2::ggplot(
      cv_cases,
      aes(
        x = weeks_since_case100,
        y = new_outcome,
        fill = region,
        group = 1,
        text = paste0("Week ", weeks_since_case100, "\n", region, ": ", new_outcome)
      )
    ) +
      xlab("Weeks since 100th confirmed case") #+ xlim(c(plot_start_date,(current_date+5)))
  }

  if (start_point == "Week of 10th death") {
    cv_cases = subset(cv_cases, weeks_since_death10 > 0)
    g = ggplot2::ggplot(
      cv_cases,
      aes(
        x = weeks_since_death10,
        y = new_outcome,
        fill = region,
        group = 1,
        text = paste0("Week ", weeks_since_death10, "\n", region, ": ", new_outcome)
      )
    ) +
      xlab("Weeks since 10th death") #+ xlim(c(plot_start_date,(current_date+5)))
  }

  g1 = g +
    geom_bar(position = "stack", stat = "identity") +
    ylab("New (weekly)") + theme_bw() +
    # scale_fill_manual(values = country_cols) +
    scale_fill_manual(values = cls()) +
    theme(
      legend.title = element_blank(),
      legend.position = "",
      plot.title = element_text(size = 10)
    )
  plotly::ggplotly(g1, tooltip = c("text")) %>% layout(legend = list(font = list(size =
                                                                                   11)))
}

#' @title country_cases_cumulative
#' @description a function to plot cumulative cases of covid by region
#' @param cv_cases dataframe
#' @param start_point character string indicating point of origin
#' @param plot_start_date Date variable

#' @importFrom plotly ggplotly
#' @import ggplot2
#'
#' @usage country_cases_cumulative(cv_cases, start_point, plot_start_date)
#' @export
country_cases_cumulative <- function(cv_cases,
                                     start_point = c("Date", "Week of 100th confirmed case", "Week of 10th death"),
                                     plot_start_date) {
  if (start_point == "Date") {
    g = ggplot2::ggplot(cv_cases,
                        aes(
                          x = date,
                          y = outcome,
                          colour = region,
                          group = 1,
                          text = paste0(format(date, "%d %B %Y"), "\n", region, ": ", outcome)
                        )) +
      xlim(c(plot_start_date, (current_date + 1))) + xlab("Date")
  }

  if (start_point == "Week of 100th confirmed case") {
    cv_cases = subset(cv_cases, weeks_since_case100 > 0)
    g = ggplot(
      cv_cases,
      aes(
        x = weeks_since_case100,
        y = outcome,
        colour = region,
        group = 1,
        text = paste0("Week ", weeks_since_case100, "\n", region, ": ", outcome)
      )
    ) +
      xlab("Weeks since 100th confirmed case")
  }

  if (start_point == "Week of 10th death") {
    cv_cases = subset(cv_cases, weeks_since_death10 > 0)
    g = ggplot(
      cv_cases,
      aes(
        x = weeks_since_death10,
        y = outcome,
        colour = region,
        group = 1,
        text = paste0("Week ", weeks_since_death10, "\n", region, ": ", outcome)
      )
    ) +
      xlab("Weeks since 10th death")
  }

  g1 = g + geom_line(alpha = 0.8) + geom_point(size = 1, alpha = 0.8) +
    ylab("Cumulative") + theme_bw() +
    # scale_colour_manual(values = country_cols) +
    scale_colour_manual(values = cls()) +
    theme(
      legend.title = element_blank(),
      legend.position = "",
      plot.title = element_text(size = 10)
    )
  plotly::ggplotly(g1, tooltip = c("text")) %>% layout(legend = list(font = list(size =
                                                                                   11)))
}

#' @title country_cases_cumulative_log
#' @description a function to plot cumulative cases of covid on log10 scale by region
#' @param cv_cases dataframe
#' @param start_point character string indicating point of origin
#' @param plot_start_date Date variable
#' @import ggplot2
#' @importFrom plotly ggplotly
#'
#' @usage country_cases_cumulative_log(cv_cases, start_point, plot_start_date)
#' @export
country_cases_cumulative_log <- function(cv_cases,
                                         start_point = c("Date", "Week of 100th confirmed case", "Week of 10th death"),
                                         plot_start_date)  {
  if (start_point == "Date") {
    g = ggplot2::ggplot(cv_cases,
                        aes(
                          x = date,
                          y = outcome,
                          colour = region,
                          group = 1,
                          text = paste0(format(date, "%d %B %Y"), "\n", region, ": ", outcome)
                        )) +
      xlim(c(plot_start_date, (current_date + 1))) + xlab("Date")
  }

  if (start_point == "Week of 100th confirmed case") {
    cv_cases = subset(cv_cases, weeks_since_case100 > 0)
    g = ggplot(
      cv_cases,
      aes(
        x = weeks_since_case100,
        y = outcome,
        colour = region,
        group = 1,
        text = paste0("Week ", weeks_since_case100, "\n", region, ": ", outcome)
      )
    ) +
      xlab("Weeks since 100th confirmed case")
  }

  if (start_point == "Week of 10th death") {
    cv_cases = subset(cv_cases, weeks_since_death10 > 0)
    g = ggplot2::ggplot(
      cv_cases,
      aes(
        x = weeks_since_death10,
        y = outcome,
        colour = region,
        group = 1,
        text = paste0("Week ", weeks_since_death10, "\n", region, ": ", outcome)
      )
    ) +
      xlab("Weeks since 10th death")
  }

  g1 = g + geom_line(alpha=0.8) + geom_point(size = 1, alpha = 0.8) +
    ylab("Cumulative (log10)") + theme_bw() +
    scale_y_continuous(trans="log10") +
    # scale_colour_manual(values=country_cols) +
    scale_colour_manual(values=cls()) +
    theme(legend.title = element_blank(), legend.position = "", plot.title = element_text(size=10))
  plotly::ggplotly(g1, tooltip = c("text")) %>% layout(legend = list(font = list(size=11)))
}

# # create plotting parameters for map
# bins <- c(0,10,50,100,500,1000,Inf)
# cv_pal <- leaflet::colorBin("Oranges", domain = cv_large_countries$cases_per_million, bins = bins)
# plot_map <- worldcountry[worldcountry$ADM0_A3 %in% cv_large_countries$alpha3, ]

#' create a color palette using leaflet::colorBin
#'
#' @param bins numeric vector
#' @param df dataframe
#' @importFrom leaflet colorBin

#' @export
#'
#' @usage pal(bins, df)
pal <- function(bins = c(0,10,50,100,500,1000,Inf), df = cv_large_countries ){
  cv_pal <- leaflet::colorBin("Oranges", domain = df$cases_per_million, bins = bins)
  cv_pal
}

#' @title country_cases_cumulative_log
#' @description a function to cv base map
#' @param p_map a shape file


#' @import leaflet
#'
#' @usage base_map(p_map)
#' @export
base_map <- function(p_map = plot_map){
  basemap <- leaflet::leaflet(p_map) %>%
    addTiles() %>%
    addLayersControl(
      position = "bottomright",
      overlayGroups = c("2019-COVID (new)", "2019-COVID (cumulative)"#, "2003-SARS", "2009-H1N1 (swine flu)", "2014-Ebola"
      ),
      options = layersControlOptions(collapsed = FALSE)) %>%
    hideGroup(c("2019-COVID (cumulative)", "2003-SARS"
                , "2009-H1N1 (swine flu)", "2014-Ebola"
    )) %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    fitBounds(~-100,-60,~60,70) %>%
    addLegend("bottomright", pal = pal(), values = ~cv_large_countries$deaths_per_million,
              title = "<small>Deaths per million</small>")
  basemap
}

