# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
#
###################################
#### CURRENT FILE: DEV SCRIPT #####
###################################

# 2. All along your project

# golem::add_fct("nav")
# golem::add_fct("row")

# add functions

golem::add_fct("plot")


## 2.1 Add modules

golem::add_module(name = "about")
golem::add_module(name = "region")
golem::add_module(name = "map")
golem::add_module(name = "data")

# golem::add_utils("ui", "dataviz")

## 2.2 Add dependencies

usethis::use_package("glue")
usethis::use_package("rlang")
usethis::use_package("dplyr")
usethis::use_package("styler")
usethis::use_package("withr")
usethis::use_package("colourvalues")
usethis::use_package("markdown")
usethis::use_package("geojsonio")
usethis::use_package("leaflet")
usethis::use_package("plotly")
usethis::use_package("ggiraph")
usethis::use_package("maps")
usethis::use_package("ggplot2")
usethis::use_package("RColorBrewer")
usethis::use_package("shinyWidgets")

# start
usethis::use_pipe()

attachment::att_amend_desc()
usethis::use_package("markdown")

## 2.3 Add tests

usethis::use_test("app")

## 2.4 Add a browser button
golem::browser_button()

## 2.5 Add external files

# golem::add_js_file("script")
# golem::add_js_handler("handlers")
golem::add_css_file("styles")

# 3. Documentation

## 3.1 Vignette

usethis::use_vignette("COVID19Dash")
devtools::build_vignettes()

## 3.2 Code coverage
## You'll need Github
usethis::use_github(protocol = "ssh")

# All set
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")

