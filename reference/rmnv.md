# Simulate from a Multivariate Normal Distribution

Simulate from a Multivariate Normal Distribution

## Usage

``` r
rmnv(n, mean_v, cor_mtx, treatment = "trt", ...)
```

## Arguments

- n:

  number of samples

- mean_v:

  vector of means

- cor_mtx:

  correlation matrix for input variables

- treatment:

  treatment column value (character/scalar)

- ...:

  additional parameters passed to
  [`mvrnorm`](https://rdrr.io/pkg/MASS/man/mvrnorm.html)
