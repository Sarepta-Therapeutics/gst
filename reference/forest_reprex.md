# Create reproducible code for current forestplot

Create reproducible code for current forestplot

## Usage

``` r
forest_reprex(forestplot, unfold = FALSE)
```

## Arguments

- forestplot:

  output from forest_plot()

- unfold:

  unfold the
  [`forest_plot`](https://sarepta-therapeutics.github.io/gst/reference/forest_plot.md)
  function? (logical/scalar; default = FALSE)

## Note

Unfolding the code (`unfold = T`) will generate a code snippet that uses
the `forestploter` package functions directly; the resulting code does
not require the `gst` package.

WARNING: This function will not create a perfect reprex if you use the
`...` argument in
[`forest_plot`](https://sarepta-therapeutics.github.io/gst/reference/forest_plot.md)
