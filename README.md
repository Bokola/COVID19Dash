
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `{COVID19Dash}`

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

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
  [`{ggplot2}`](https://github.com/tidyverse/ggplot2)

- The UI was built with [`Boostrap`](https://getbootstrap.com/)

- The app was deployed on [RStudio
  Connect](https://rstudio.com/products/connect/)

Browse the full source code at <https://github.com/bokola/covid19dash>

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-11-13 17:00:57 EAT"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading COVID19Dash
#> ── R CMD check results ───────────────────────────── COVID19Dash 0.0.0.9000 ────
#> Duration: 47.1s
#> 
#> ❯ checking for future file timestamps ... NOTE
#>   unable to verify current time
#> 
#> ❯ checking top-level files ... NOTE
#>   Non-standard files/directories found at top level:
#>     ‘CODE_OF_CONDUCT.md’ ‘LICENSE.md’ ‘README.Rmd’
#> 
#> ❯ checking package subdirectories ... NOTE
#>   Problems with news in ‘NEWS.md’:
#>   No news entries found.
#> 
#> ❯ checking dependencies in R code ... NOTE
#>   Namespaces in Imports field not imported from:
#>     ‘RColorBrewer’ ‘ggplot2’
#>     All declared Imports should be used.
#> 
#> 0 errors ✔ | 0 warnings ✔ | 4 notes ✖
```

``` r
covr::package_coverage()
#> COVID19Dash Coverage: 52.67%
#> R/run_app.R: 0.00%
#> R/globals.R: 18.34%
#> R/mod_about.R: 18.75%
#> R/mod_region.R: 23.93%
#> R/mod_data.R: 52.05%
#> R/mod_map.R: 53.46%
#> R/app_server.R: 81.25%
#> R/app_config.R: 100.00%
#> R/app_ui.R: 100.00%
#> R/golem_utils_server.R: 100.00%
#> R/golem_utils_ui.R: 100.00%
```
