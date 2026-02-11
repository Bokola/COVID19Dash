
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

For predictions go to `Prediction Model` tab.

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
#> [1] "2026-02-11 09:30:19 EAT"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading COVID19Dash
#> Error in `loadNamespace()`:
#> ! there is no package called 'function'
```

``` r
covr::package_coverage()
#> Warning in utils::install.packages(repos = NULL, lib = install_path, pkg$path,
#> : installation of package '/home/basil-owiti/COVID19Dash' had non-zero exit
#> status
#> Warning in file(con, "r"): cannot open file
#> '/tmp/RtmprrwHfx/R_LIBS353553eea87f/COVID19Dash/R/COVID19Dash': No such file or
#> directory
#> Error in `file()`:
#> ! cannot open the connection
```
