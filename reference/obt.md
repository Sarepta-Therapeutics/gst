# Perform Obrien truncated closed testing

Perform Obrien truncated closed testing

## Usage

``` r
obt(
  data,
  endpoint_vars,
  jendpoint = NULL,
  treatment_vars,
  alpha = 0.05,
  nu = 0.8,
  method = c("ols", "gls", "ranksum"),
  var.equal = TRUE,
  ...
)
```

## Arguments

- data:

  input data; columns should contain endpoint data and must be named E1,
  E2

- endpoint_vars:

  vector of endpoint column names (character/vector)

- jendpoint:

  joint endpoint, a vector of individual endpoints (character/vector)

- treatment_vars:

  treatment column name (character/scalar)

- alpha:

  significance level (numeric/scalar)

- nu:

  truncation parameter, between 0 and 1 (numeric/scalar; default = 0.8)

- method:

  estimation method (character/scalar; default = 'OLS')

- var.equal:

  assume equal variances? (logical/scalar; default = TRUE)

- ...:

  additional arguments passed to
  [`obrien`](https://sarepta-therapeutics.github.io/gst/reference/obrien.md)

## Value

a list containing the following elements:

- `F`: target family of hypotheses (character/vector)

- `df`: data.frame with relevant hypotheses and parameters

- `df_gst`: data.frame with results from the different procedures

- `alpha_A`: unused alpha available for propagation to the next family

## Note

This is the truncated closed test as proposed by: Luo, X., Li, L.,
Savenkov, O., Liu, W., Ni, X., Tang, W. and Guo, W., 2025. Multiple
Comparisons Procedures for Analyses of Joint Primary Endpoints and
Secondary Endpoints. Pharmaceutical Statistics, 24(3), p.e70010

## Input Data Requirements

The endpoint variables in `data` must be named `E1`, `E2`, `E3`, etc.
for the function to work correctly. If you endpoint columns do not have
this naming convention, you must rename them.

## Examples

``` r
dat <- multcomp::mtept
dat$E4 <- -dat$E4  # align signs for all endpoints
obt(
    data = dat,
    endpoint_vars = c("E1","E2","E3","E4"),
    jendpoint = c("E3", "E4"),
    alpha = 0.05,
    nu = 0.6,
    treatment_vars = "treatment",
    method = "ols"
)
#> Number of intersection hypotheses: 31
#> Number of unique intersection hypotheses: 18
#> $F
#> [1] "G"  "H1" "H2" "H3" "H4"
#> 
#> $df
#> Warning: restarting interrupted promise evaluation
#> Warning: internal error -3 in R_decompress1
#> Error in get_extent(format_type_sum(type, NULL)): lazy-load database '/usr/home/prburns/R/x86_64-pc-linux-gnu-library/4.3/utf8/R/utf8.rdb' is corrupt
```
