# Calculate sample size

Calculate sample size

## Usage

``` r
get_n(
  power,
  es0,
  es1,
  R,
  alpha = 0.05,
  k,
  method = c("ols", "gls"),
  df_method = c("vd", "vob", "vlt"),
  n0_range = c(2, 1000),
  tolerance = 1e-06
)
```

## Arguments

- power:

  target power

- es0:

  effect size in endpoint 1

- es1:

  effect size in endpoint 2

- R:

  correlation matrix between endpoints

- alpha:

  significance level

- k:

  sample size ratio of treatment vs placebo

- method:

  obrien "ols", "gls"

- df_method:

  degrees-of-freedom method (one of: vd, vob, vlt)

- n0_range:

  range of size in placebo to be searched

- tolerance:

  the desired accuracy (convergence tolerance)

## Value

power
