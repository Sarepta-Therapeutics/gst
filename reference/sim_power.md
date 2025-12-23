# Calculate Power by simulation

Calculate Power by simulation

## Usage

``` r
sim_power(
  n0,
  n1 = n0,
  lambda,
  R,
  alpha = 0.05,
  N = 1000,
  ncore = 4,
  method = c("ols", "gls"),
  ...
)
```

## Arguments

- n0:

  sample size in placebo group

- n1:

  sample size in treatment group

- lambda:

  vector of effect size for each endpoint

- R:

  correlation matrix of lambda

- alpha:

  significance level

- N:

  number of replication

- ncore:

  n of cores planned

- method:

  obrien "ols", "gls"

- ...:

  additional arguments passed to
  [`obrien`](https://sarepta-therapeutics.github.io/gst/reference/obrien.md)

## Value

power
