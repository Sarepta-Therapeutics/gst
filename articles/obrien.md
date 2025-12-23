# O'Brien's Test

## Background

O’Brien’s OLS statistic is the sum of the t-statistics that are obtained
by standardizing the individual endpoints by their pooled within-group
sample standard deviations. The GLS statistic is the weighted version of
OLS.

## Examples

We provide the
[`obrien()`](https://sarepta-therapeutics.github.io/gst/reference/obrien.md)
function to conduct O’Brien’s statistical test on multiple endpoints
across two (treatment) groups.

The input dataset should have a treatment column and then one additional
column for each outcome (i.e., wide-format). For our examples we will
use the `mtept` dataset that is included with the `multcomp` package.

``` r
library(gst)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

# load data from the `multcomp` package
dat <- multcomp::mtept
head(dat)
#>    treatment E1 E2 E3 E4
#> 1    Placebo  4  3  3  5
#> 5    Placebo  5  0  1  7
#> 9    Placebo  1  0  1  9
#> 13   Placebo  4  0  3  5
#> 17   Placebo  3  0  2  9
#> 21   Placebo  4  1  2  6
```

One important point is that O’Brien’s test is directional in nature.
Therefore, it is important to adjust outcome metrics such that *similar
directions indicate similar outcomes* – e.g., if a positive effect for
E4 and a negative effect for E1 both indicate a positive outcome for the
patient, then signs should be reversed to align positive outcomes across
endpoints. In other words, **all endpoints should be either positively
or negatively correlated (but not both).**

``` r
# correlation between endpoints
dat |> 
  select(-treatment) |> 
  cor()
#>            E1         E2         E3         E4
#> E1  1.0000000  0.4166472  0.6437159 -0.7112218
#> E2  0.4166472  1.0000000  0.4605603 -0.4555092
#> E3  0.6437159  0.4605603  1.0000000 -0.6391847
#> E4 -0.7112218 -0.4555092 -0.6391847  1.0000000
```

For this data, we can see E1, E2, and E3 are positively correlated.
However, E4 is negatively correlated with the other endpoints.
Therefore, we need to reverse the direction of E4 before testing.

``` r
# reverse E4
dat <- dat |>
  mutate(
    E4 = -E4
  )

# correlation between endpoints
dat |> 
  select(-treatment) |> 
  cor()
#>           E1        E2        E3        E4
#> E1 1.0000000 0.4166472 0.6437159 0.7112218
#> E2 0.4166472 1.0000000 0.4605603 0.4555092
#> E3 0.6437159 0.4605603 1.0000000 0.6391847
#> E4 0.7112218 0.4555092 0.6391847 1.0000000
```

### Example 1 - OLS with equal variances

For example, let’s perform O’Brien’s test using the OLS method with
equal variances (default).

``` r
results <- dat |>
  obrien(
    endpoint_vars = c("E1", "E2", "E3", "E4"),
    treatment_vars = "treatment",
    method = "ols"
  )
print(data.frame(results[-5]))
#>   statistic  df      pvalue alternative
#> t -2.697624 109 0.008094326   two.sided
```

### Example 2 - GLS with equal variances

``` r
results <- dat |>
  obrien(
    endpoint_vars = c("E1", "E2", "E3", "E4"),
    treatment_vars = "treatment",
    method = "gls"
  )
print(data.frame(results[-5]))
#>   statistic  df      pvalue alternative
#> t -2.812559 109 0.005830776   two.sided
```

### Example 3 - Ranksum with equal variances

``` r
results <- dat |>
  obrien(
    endpoint_vars = c("E1", "E2", "E3", "E4"),
    treatment_vars = "treatment",
    method = "ranksum" 
  )
print(data.frame(results[-5]))
#>   statistic  df     pvalue alternative
#> t -2.084701 109 0.03943257   two.sided
```

### Example 4 - All Endpoints, All Methods

In this example, we perform the OLS equal variances method on all
possible combinations of the 4 endpoints.

``` r
# generate all possible combinations of the 4 endpoints (1 = include; 0 = exclude)
opt_mat <- expand.grid(0:1, 0:1, 0:1, 0:1)
opt_mat <- opt_mat |> dplyr::arrange(rowSums(opt_mat))
endpoints <- c("E1", "E2", "E3", "E4")

# run o'brien's test on each combination of endpoints
results <- 
  purrr::map_dfr(
    2:nrow(opt_mat),
    function(i) {
      my_endpoints <- endpoints[ opt_mat[i, ] == 1 ]  # identify endpoints to test
      x <- dat |>
        obrien(
          endpoint_vars = my_endpoints,
          treatment_vars = "treatment",
          method = "ols" 
        )
      x$R <- NULL    # ignore correlation matrix in output (not needed)
      x |>
        dplyr::as_tibble() |>
        dplyr::mutate(
          endpoints = paste(my_endpoints, collapse = ", "),
          method = "ols"
        )
    }
  )

# display results in a nice table
results |>
  dplyr::transmute(
    Endpoints = endpoints,
    DF = df,
    `Test Statistic` = round(statistic, 2),
    `P-value` = round(pvalue, 3)
  ) |>
  gt::gt() |>
  gt::fmt_auto() |>
  gt::tab_header(
    "O'Brien's OLS Test on All Endpoint Combinations"
  )
```

| O'Brien's OLS Test on All Endpoint Combinations |      |                |         |
|-------------------------------------------------|------|----------------|---------|
| Endpoints                                       | DF   | Test Statistic | P-value |
| E1                                              | 109  | −2.55          | 0.012   |
| E2                                              | 109  | −2.49          | 0.014   |
| E3                                              | 109  | −1.29          | 0.199   |
| E4                                              | 109  | −2.38          | 0.019   |
| E1, E2                                          | 109  | −3.03          | 0.003   |
| E1, E3                                          | 109  | −2.13          | 0.036   |
| E2, E3                                          | 109  | −2.22          | 0.028   |
| E1, E4                                          | 109  | −2.68          | 0.009   |
| E2, E4                                          | 109  | −2.88          | 0.005   |
| E3, E4                                          | 109  | −2.03          | 0.044   |
| E1, E2, E3                                      | 109  | −2.6           | 0.011   |
| E1, E2, E4                                      | 109  | −3.03          | 0.003   |
| E1, E3, E4                                      | 109  | −2.36          | 0.02    |
| E2, E3, E4                                      | 109  | −2.51          | 0.013   |
| E1, E2, E3, E4                                  | 109  | −2.7           | 0.008   |

### Additional Considerations

Example 4 provides a nice illustration of how including additional
endpoints impact the global statistical test (GST). In particular, E3 is
not significant ($\alpha = 0.05$) on it’s own, but is significant when
considered jointly with any other endpoint.

Another observation is that if we had not reversed the direction of E4,
we would have seen a non-significant result for the combination of {E1,
E4} despite them both being significant individually and jointly after
reversing E4.
