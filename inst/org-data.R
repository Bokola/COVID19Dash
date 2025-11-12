# import data
cv_cases <- read.csv("data-raw/coronavirus.csv")
countries <- read.csv("data-raw/countries_codes_and_coordinates.csv")
worldcountry <- geojsonio::geojson_read("data-raw/50m.geojson", what = "sp")
cv_states <- read.csv("data-raw/coronavirus_states.csv")

# dir.create("data", recursive = TRUE)

# save(worldcountry, file = file.path("data", "worldcountry.rda"))

### DATA PROCESSING: COVID-19 ###

# extract time stamp from cv_cases
update = tail(cv_cases$last_update,1)

# check consistency of country names across datasets
if (all(unique(cv_cases$country) %in% unique(countries$country))==FALSE) { print("Error: inconsistent country names")}

# extract dates from cv data
if (any(grepl("/", cv_cases$date))) {
  cv_cases$date = format(as.Date(cv_cases$date, format="%d/%m/%Y"),"%Y-%m-%d")
} else { cv_cases$date = as.Date(cv_cases$date, format="%Y-%m-%d") }
cv_cases$date = as.Date(cv_cases$date)
cv_min_date = as.Date(min(cv_cases$date),"%Y-%m-%d")
current_date = as.Date(max(cv_cases$date),"%Y-%m-%d")
cv_max_date_clean = format(as.POSIXct(current_date),"%d %B %Y")

# merge cv data with country data and extract key summary variables
cv_cases = merge(cv_cases, countries, by = "country")
cv_cases = cv_cases[order(cv_cases$date),]
cv_cases$cases_per_million = as.numeric(format(round(cv_cases$cases/(cv_cases$population/1000000),1),nsmall=1))
cv_cases$new_cases_per_million = as.numeric(format(round(cv_cases$new_cases/(cv_cases$population/1000000),1),nsmall=1))
cv_cases$million_pop = as.numeric(cv_cases$population>1e6)
cv_cases$deaths_per_million = as.numeric(format(round(cv_cases$deaths/(cv_cases$population/1000000),1),nsmall=1))
cv_cases$new_deaths_per_million = as.numeric(format(round(cv_cases$new_deaths/(cv_cases$population/1000000),1),nsmall=1))

# add variable for weeks since 100th case and 10th death
cv_cases$weeks_since_case100 = cv_cases$weeks_since_death10 = 0
for (i in 1:length(unique(cv_cases$country))) {
  country_name = as.character(unique(cv_cases$country))[i]
  country_db = subset(cv_cases, country==country_name)
  country_db$weeks_since_case100[country_db$cases>=100] = 0:(sum(country_db$cases>=100)-1)
  country_db$weeks_since_death10[country_db$deaths>=10] = 0:(sum(country_db$deaths>=10)-1)
  cv_cases$weeks_since_case100[cv_cases$country==country_name] = country_db$weeks_since_case100
  cv_cases$weeks_since_death10[cv_cases$country==country_name] = country_db$weeks_since_death10
}

# creat variable for today's data
cv_today = subset(cv_cases, date==current_date)
current_case_count = sum(cv_today$cases)
current_case_count_China = sum(cv_today$cases[cv_today$country=="Mainland China"])
current_case_count_other = sum(cv_today$cases[cv_today$country!="Mainland China"])
current_death_count = sum(cv_today$deaths)

# create subset of state data for today's data
if (any(grepl("/", cv_states$date))) {
  cv_states$date = format(as.Date(cv_states$date, format="%d/%m/%Y"),"%Y-%m-%d")
} else { cv_states$date = as.Date(cv_states$date, format="%Y-%m-%d") }
cv_states_today = subset(cv_states, date==max(cv_states$date))

# create subset for countries with at least 1000 cases
cv_today_reduced = subset(cv_today, cases>=1000)

# write current day's data
write.csv(cv_today %>% select(c(country, date, update, cases, new_cases, deaths, new_deaths,
                                cases_per_million, new_cases_per_million,
                                deaths_per_million, new_deaths_per_million,
                                weeks_since_case100, weeks_since_death10)), "data-raw/coronavirus_today.csv")

# aggregate at continent level
cv_cases_continent = subset(cv_cases, !is.na(continent_level)) %>%
  select(c(cases, new_cases, deaths, new_deaths, date, continent_level)) %>%
  group_by(continent_level, date) %>% summarise_each(funs(sum)) %>% data.frame()

# add variable for weeks since 100th case and 10th death
cv_cases_continent$weeks_since_case100 = cv_cases_continent$weeks_since_death10 = 0
cv_cases_continent$continent = cv_cases_continent$continent_level
for (i in 1:length(unique(cv_cases_continent$continent))) {
  continent_name = as.character(unique(cv_cases_continent$continent))[i]
  continent_db = subset(cv_cases_continent, continent==continent_name)
  continent_db$weeks_since_case100[continent_db$cases>=100] = 0:(sum(continent_db$cases>=100)-1)
  continent_db$weeks_since_death10[continent_db$deaths>=10] = 0:(sum(continent_db$deaths>=10)-1)
  cv_cases_continent$weeks_since_case100[cv_cases_continent$continent==continent_name] = continent_db$weeks_since_case100
  cv_cases_continent$weeks_since_death10[cv_cases_continent$continent==continent_name] = continent_db$weeks_since_death10
}

# add continent populations
cv_cases_continent$pop = NA
cv_cases_continent$pop[cv_cases_continent$continent=="Africa"] = 1.2e9
cv_cases_continent$pop[cv_cases_continent$continent=="Asia"] = 4.5e9
cv_cases_continent$pop[cv_cases_continent$continent=="Europe"] = 7.4e8
cv_cases_continent$pop[cv_cases_continent$continent=="North America"] = 5.8e8
cv_cases_continent$pop[cv_cases_continent$continent=="Oceania"] = 3.8e7
cv_cases_continent$pop[cv_cases_continent$continent=="South America"] = 4.2e8

# add normalised counts
cv_cases_continent$cases_per_million =  as.numeric(format(round(cv_cases_continent$cases/(cv_cases_continent$pop/1000000),1),nsmall=1))
cv_cases_continent$new_cases_per_million =  as.numeric(format(round(cv_cases_continent$new_cases/(cv_cases_continent$pop/1000000),1),nsmall=1))
cv_cases_continent$deaths_per_million =  as.numeric(format(round(cv_cases_continent$deaths/(cv_cases_continent$pop/1000000),1),nsmall=1))
cv_cases_continent$new_deaths_per_million =  as.numeric(format(round(cv_cases_continent$new_deaths/(cv_cases_continent$pop/1000000),1),nsmall=1))
write.csv(cv_cases_continent, "input_data/coronavirus_continent.csv")

# aggregate at global level
cv_cases_global = cv_cases %>% select(c(cases, new_cases, deaths, new_deaths, date, global_level)) %>% group_by(global_level, date) %>% summarise_each(funs(sum)) %>% data.frame()
cv_cases_global$weeks_since_case100 = cv_cases_global$weeks_since_death10 = 0:(nrow(cv_cases_global)-1)

# add normalised counts
cv_cases_global$pop = 7.6e9
cv_cases_global$cases_per_million =  as.numeric(format(round(cv_cases_global$cases/(cv_cases_global$pop/1000000),1),nsmall=1))
cv_cases_global$new_cases_per_million =  as.numeric(format(round(cv_cases_global$new_cases/(cv_cases_global$pop/1000000),1),nsmall=1))
cv_cases_global$deaths_per_million =  as.numeric(format(round(cv_cases_global$deaths/(cv_cases_global$pop/1000000),1),nsmall=1))
cv_cases_global$new_deaths_per_million =  as.numeric(format(round(cv_cases_global$new_deaths/(cv_cases_global$pop/1000000),1),nsmall=1))
write.csv(cv_cases_global, "input_data/coronavirus_global.csv")

# select large countries for mapping polygons
cv_large_countries = cv_today %>% filter(alpha3 %in% worldcountry$ADM0_A3)
if (all(cv_large_countries$alpha3 %in% worldcountry$ADM0_A3)==FALSE) { print("Error: inconsistent country names")}
cv_large_countries = cv_large_countries[order(cv_large_countries$alpha3),]

# create plotting parameters for map
bins = c(0,10,50,100,500,1000,Inf)
cv_pal <- colorBin("Oranges", domain = cv_large_countries$cases_per_million, bins = bins)
plot_map <- worldcountry[worldcountry$ADM0_A3 %in% cv_large_countries$alpha3, ]

# creat cv base map
basemap = leaflet(plot_map) %>%
  addTiles() %>%
  addLayersControl(
    position = "bottomright",
    overlayGroups = c("2019-COVID (new)", "2019-COVID (cumulative)", "2003-SARS", "2009-H1N1 (swine flu)", "2014-Ebola"),
    options = layersControlOptions(collapsed = FALSE)) %>%
  hideGroup(c("2019-COVID (cumulative)", "2003-SARS", "2009-H1N1 (swine flu)", "2014-Ebola")) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  fitBounds(~-100,-60,~60,70) %>%
  addLegend("bottomright", pal = cv_pal, values = ~cv_large_countries$deaths_per_million,
            title = "<small>Deaths per million</small>")

# sum cv case counts by date
cv_aggregated = aggregate(cv_cases$cases, by=list(Category=cv_cases$date), FUN=sum)
names(cv_aggregated) = c("date", "cases")

# add variable for new cases in last 7 days
for (i in 1:nrow(cv_aggregated)) {
  if (i==1) { cv_aggregated$new[i] = 0 }
  if (i>1) { cv_aggregated$new[i] = cv_aggregated$cases[i] - cv_aggregated$cases[i-1] }
}

# add plotting region
cv_aggregated$region = "Global"
cv_aggregated$date = as.Date(cv_aggregated$date,"%Y-%m-%d")

# assign colours to countries to ensure consistency between plots
cls = rep(c(brewer.pal(8,"Dark2"), brewer.pal(10, "Paired"), brewer.pal(12, "Set3"), brewer.pal(8,"Set2"), brewer.pal(9, "Set1"), brewer.pal(8, "Accent"),  brewer.pal(9, "Pastel1"),  brewer.pal(8, "Pastel2")),4)
cls_names = c(as.character(unique(cv_cases$country)), as.character(unique(cv_cases_continent$continent)), as.character(unique(cv_states$state)),"Global")
country_cols = cls[1:length(cls_names)]
names(country_cols) = cls_names


# creat variable for today's data
cv_today = subset(cv_cases, date==current_date)
current_case_count = sum(cv_today$cases)
current_case_count_China = sum(cv_today$cases[cv_today$country=="Mainland China"])
current_case_count_other = sum(cv_today$cases[cv_today$country!="Mainland China"])
current_death_count = sum(cv_today$deaths)

# # create subset of state data for today's data
# if (any(grepl("/", cv_states$date))) {
#   cv_states$date = format(as.Date(cv_states$date, format="%d/%m/%Y"),"%Y-%m-%d")
# } else { cv_states$date = as.Date(cv_states$date, format="%Y-%m-%d") }
# cv_states_today = subset(cv_states, date==max(cv_states$date))

# create subset for countries with at least 1000 cases
cv_today_reduced = subset(cv_today, cases>=1000)

save(cv_cases, file = file.path("data", "cv_cases.rda"))
save(cv_cases_continent, file = file.path("data", "cv_cases_continent.rda"))
save(cv_cases_global, file = file.path("data", "cv_cases_global.rda"))
save(cv_aggregated, file = file.path("data", "cv_aggregated.rda"))
save(cv_large_countries, file = file.path("data", "cv_large_countries.rda"))
save(cv_today_reduced, file = file.path("data", "cv_today_reduced.rda"))
