
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{COVID19Dash}`

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

![](inst/landing.png)

## Installation

You can install the development version of `{COVID19Dash}` like so:

``` r
devtools::install_github("bokola/COVID19Dash")
```

## Run

You can launch the application by running:

``` r
COVID19Dash::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

## About this app

This app was originally built by [Parker &
Leclerc](https://vac-lshtm.shinyapps.io/ncov_tracker/#) to visualize
COVID-19 cases and deaths. What’s presented here is a conversion of
parts of it to a modularized `{golem}` framework by [Basil
Okola](https://github.com/bokola).

## Tech used in this app

- The [`{golem}`](https://github.com/ThinkR-open/golem) Framework was
  used to build the Shiny App backend.

- The whole app is powered by
  [`{shiny}`](https://github.com/rstudio/shiny).

- Data visualization is done with
  [`{ggplot2}`](https://github.com/tidyverse/ggplot2),
  [`{leaflet}`](https://github.com/rstudio/leaflet), and
  [`{plotly}`](https://github.com/plotly/plotly.R)

- The UI was built with [`Boostrap`](https://getbootstrap.com/)

- Docker images for both [shinyproxy](https://www.shinyproxy.io/) and
  [heroku](https://www.heroku.com/) were built

- A docker container image was pushed to
  [dockerhub](https://hub.docker.com/)

Browse the full source code at <https://github.com/bokola/covid19dash>

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-11-14 14:55:10 EAT"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading COVID19Dash
#> Warning: replacing previous import 'ggplot2::last_plot' by 'plotly::last_plot'
#> when loading 'COVID19Dash'
#> Loading required namespace: sp
#> ── R CMD check results ───────────────────────────── COVID19Dash 0.0.0.9000 ────
#> Duration: 47.1s
#> 
#> ❯ checking whether package ‘COVID19Dash’ can be installed ... WARNING
#>   See below...
#> 
#> 0 errors ✔ | 1 warning ✖ | 0 notes ✔
#> Error: R CMD check found WARNINGs
```

``` r
covr::package_coverage()
#> COVID19Dash Coverage: 52.48%
#> R/run_app.R: 0.00%
#> R/mod_about.R: 18.75%
#> R/mod_region.R: 23.93%
#> R/fct_plot.R: 24.27%
#> R/mod_map.R: 52.47%
#> R/mod_data.R: 52.70%
#> R/app_server.R: 81.25%
#> R/app_config.R: 100.00%
#> R/app_ui.R: 100.00%
#> R/golem_utils_server.R: 100.00%
#> R/golem_utils_ui.R: 100.00%
```
