# O’Brien test

O’Brien test

## Usage

``` r
obrien(
  data,
  endpoint_vars,
  treatment_vars,
  method = c("ols", "gls", "ranksum"),
  var.equal = TRUE,
  ...
)
```

## Arguments

- data:

  dataset with treatment and multiple outcomes in wide format

- endpoint_vars:

  the character vectors of outcomes in the dataset dat

- treatment_vars:

  treatment varialbe in the dataset dat

- method:

  obrien "ols", "gls" and "ranksum" test

- var.equal:

  default TRUE. the obrien paper assumes equal variance and using pooled
  variance to standardize data

- ...:

  other options passed to
  [`t.test`](https://rdrr.io/r/stats/t.test.html) and
  [`wilcox.test`](https://rdrr.io/r/stats/wilcox.test.html)

## Value

A list with t-statistic, df, pvalue, alternative, and correlation matrix
R

## Examples

``` r
# prepare example data (from multcomp::mtept)
dat <- multcomp::mtept
dat$E4 <- -dat$E4  # align signs for all endpoint

# OLS method
dat |>
   obrien(
     endpoint_vars = c("E1", "E2", "E3", "E4"),
     treatment_vars = "treatment",
     method = "ols"
     )
#> $statistic
#>         t 
#> -2.697624 
#> 
#> $df
#>  df 
#> 109 
#> 
#> $pvalue
#> [1] 0.008094326
#> 
#> $alternative
#> [1] "two.sided"
#> 
#> $R
#>           E1        E2        E3        E4
#> E1 1.0000000 0.3826183 0.6374516 0.6952211
#> E2 0.3826183 1.0000000 0.4475470 0.4259170
#> E3 0.6374516 0.4475470 1.0000000 0.6323512
#> E4 0.6952211 0.4259170 0.6323512 1.0000000
#> 

# GLS one-sided
dat |>
  obrien(
    endpoint_vars = c("E1", "E2", "E3"),
    treatment_vars = "treatment",
    method = "gls",
    alternative = "less"
    )
#> $statistic
#>         t 
#> -2.726088 
#> 
#> $df
#>  df 
#> 109 
#> 
#> $pvalue
#> [1] 0.003734737
#> 
#> $alternative
#> [1] "less"
#> 
#> $R
#>           E1        E2        E3
#> E1 1.0000000 0.3826183 0.6374516
#> E2 0.3826183 1.0000000 0.4475470
#> E3 0.6374516 0.4475470 1.0000000
#> 

# Ranksum method
dat |>
  obrien(
    endpoint_vars = c("E1", "E2", "E3", "E4"),
    treatment_vars = "treatment",
    method = "ranksum"
    )
#> $statistic
#>         t 
#> -2.084701 
#> 
#> $df
#>  df 
#> 109 
#> 
#> $pvalue
#> [1] 0.03943257
#> 
#> $alternative
#> [1] "two.sided"
#> 
#> $R
#>           E1        E2        E3        E4
#> E1 1.0000000 0.3826183 0.6374516 0.6952211
#> E2 0.3826183 1.0000000 0.4475470 0.4259170
#> E3 0.6374516 0.4475470 1.0000000 0.6323512
#> E4 0.6952211 0.4259170 0.6323512 1.0000000
#> 
```
