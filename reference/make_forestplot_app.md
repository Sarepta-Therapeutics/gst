# A Shiny app to make a forest plot

A Shiny app to make a forest plot

## Usage

``` r
make_forestplot_app(runApp = TRUE, plot_width = 1000, plot_height = 500)
```

## Arguments

- runApp:

  should the app be run on completion, default is TRUE

- plot_width:

  Width of the plot in pixels, default is 1200

- plot_height:

  Height of the plot in pixels, default is 800

## Value

A Shiny app

## Examples

``` r
if (interactive()) {
  make_forestplot_app()
}
#> Warning: restarting interrupted promise evaluation
#> Warning: internal error -3 in R_decompress1
#> Error in get_icon_idx_all_types(name = name): lazy-load database '/usr/home/prburns/R/x86_64-pc-linux-gnu-library/4.3/fontawesome/R/sysdata.rdb' is corrupt
```
