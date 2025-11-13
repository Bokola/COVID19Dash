library(leaflet)
library(ggplot2)

globalVariables(
  c(
    'cv_today_reduced'
    ,'cv_large_countries'
    ,'cv_aggregated'
    ,'plot_map'
    ,'worldcountry'
    ,'cv_cases_global'
    ,'cv_cases_continent'
    ,'cv_cases'
    ,'cv_states'
  )
)

# params
data("cv_today_reduced")
data("cv_large_countries")
data("cv_aggregated")
data("plot_map")
data("worldcountry")
data("cv_cases_global")
data("cv_cases_continent")
data("cv_cases")
data("cv_states")


# create subset of state data for today's data
if (any(grepl("/", cv_states$date))) {
  cv_states$date <- format(as.Date(cv_states$date, format="%d/%m/%Y"),"%Y-%m-%d")
} else { cv_states$date = as.Date(cv_states$date, format="%Y-%m-%d") }
cv_states_today <- subset(cv_states, date==max(cv_states$date))

# set mapping colour for each outbreak
covid_col <- "#cc4c02"
covid_other_col <- "#662506"
sars_col <- "#045a8d"
h1n1_col <- "#4d004b"
ebola_col <- "#016c59"

# assign colours to countries to ensure consistency between plots
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
cls_names <- c(as.character(unique(cv_cases$country)),
              as.character(unique(cv_cases_continent$continent)),
              as.character(unique(cv_states$state)),
              "Global")
country_cols <- cls[1:length(cls_names)]
names(country_cols) <- cls_names

cv_min_date <- as.Date(min(cv_cases$date),"%Y-%m-%d")
current_date <-  as.Date(max(cv_cases$date),"%Y-%m-%d")
cv_max_date_clean <- format(as.POSIXct(current_date),"%d %B %Y")

### MAP FUNCTIONS ###
# function to plot cumulative COVID cases by date
cumulative_plot <- function(cv_aggregated, plot_date) {
  plot_df = subset(cv_aggregated, date <= plot_date)
  g1 = ggplot(plot_df, aes(x = date, y = cases, color = region)) + geom_line() + geom_point(size = 1, alpha = 0.8) +
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

# function to plot new COVID cases by date
new_cases_plot <- function(cv_aggregated, plot_date) {
  plot_df_new = subset(cv_aggregated, date <= plot_date)
  g1 = ggplot(plot_df_new, aes(x = date, y = new, colour = region)) + geom_line() + geom_point(size = 1, alpha = 0.8) +
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


# function to plot new cases by region
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
    g = ggplot(
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
    g = ggplot(
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
    scale_fill_manual(values = country_cols) +
    theme(
      legend.title = element_blank(),
      legend.position = "",
      plot.title = element_text(size = 10)
    )
  ggplotly(g1, tooltip = c("text")) %>% layout(legend = list(font = list(size =
                                                                           11)))
}

# function to plot cumulative cases by region
country_cases_cumulative <- function(cv_cases,
                                    start_point = c("Date", "Week of 100th confirmed case", "Week of 10th death"),
                                    plot_start_date) {
  if (start_point == "Date") {
    g = ggplot(cv_cases,
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
    scale_colour_manual(values = country_cols) +
    theme(
      legend.title = element_blank(),
      legend.position = "",
      plot.title = element_text(size = 10)
    )
  ggplotly(g1, tooltip = c("text")) %>% layout(legend = list(font = list(size =
                                                                           11)))
}

# function to plot cumulative cases by region on log10 scale
country_cases_cumulative_log <- function(cv_cases,
                                         start_point = c("Date", "Week of 100th confirmed case", "Week of 10th death"),
                                         plot_start_date)  {
  if (start_point == "Date") {
    g = ggplot(cv_cases,
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

  g1 = g + geom_line(alpha=0.8) + geom_point(size = 1, alpha = 0.8) +
    ylab("Cumulative (log10)") + theme_bw() +
    scale_y_continuous(trans="log10") +
    scale_colour_manual(values=country_cols) +
    theme(legend.title = element_blank(), legend.position = "", plot.title = element_text(size=10))
  ggplotly(g1, tooltip = c("text")) %>% layout(legend = list(font = list(size=11)))
}

# create plotting parameters for map
bins <- c(0,10,50,100,500,1000,Inf)
cv_pal <- leaflet::colorBin("Oranges", domain = cv_large_countries$cases_per_million, bins = bins)
# plot_map <- worldcountry[worldcountry$ADM0_A3 %in% cv_large_countries$alpha3, ]

# creat cv base map
basemap <- leaflet(plot_map) %>%
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
  addLegend("bottomright", pal = cv_pal, values = ~cv_large_countries$deaths_per_million,
            title = "<small>Deaths per million</small>")
