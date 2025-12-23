# O'Brien Plus: Analytical Power for Joint AND Any Individual Endpoint

This function analytically estimates the statistical power for the
scenario where both the O'Brien joint endpoint test is significant AND
at least one of the individual endpoints is significant. It also
calculates the power for "Joint AND a Specific Individual" (if
`ind_index` is provided). It relies on a multivariate t-distribution
approximation of the test statistics.

## Usage

``` r
obrien_plus(
  n1,
  n2 = n1,
  df = n1 + n2 - 2,
  es_ind,
  cor_mtx,
  ind_index = NULL,
  method = c("ols", "gls"),
  alpha = 0.025,
  one_sided = TRUE
)
```

## Arguments

- n1:

  Numeric, sample size for the first treatment group.

- n2:

  Numeric, sample size for the second treatment group.

- es_ind:

  Numeric vector, the standardized mean differences (Cohen's d) for each
  individual endpoint under the alternative hypothesis.

- cor_mtx:

  Numeric matrix, the correlation matrix (R) among the standardized
  individual endpoints.

- ind_index:

  Integer, the 1-based index of a specific individual endpoint for which
  "Joint AND Specific Individual" power is also calculated. Set to NULL
  if only "Joint AND Any Individual" power is desired.

- method:

  Character, the O'Brien test method to use ("ols" or "gls").

- alpha:

  Numeric, the significance level for each test (e.g., 0.05). Assumes no
  explicit multiplicity adjustment for the 'AND' or 'OR' conditions.

- one_sided:

  Logical, default TRUE. If TRUE, a one-sided test is assumed. If FALSE,
  a two-sided test is used, with a warning about power interpretation
  for positive effect sizes.

## Value

a named list containing computation settings and results, including:

- `power_joint_any` - power for joint endpoints and any additional
  endpoint

- `power_joint_one` - power for joint endpoints and a specific endpoint
  (specified by `ind_index`)

- `power_joint` - power for the joint endpoint test

- `power_ind` - power for the specific endpoint (specified by
  `ind_index`)

- `n1` - sample size for the first treatment group

- `n2` - sample size for the second treatment group

- `alpha` - significance level

- `method` - the O'Brien test method used

- `one_sided` - logical indicating if the test is one-sided

## Examples

``` r
# Generate GST power for 3 endpoints (joint + any)
obrien_plus(
  n1 = 25,
  n2 = 30,
  es_ind = c(1, 0.5, 0.5),
  cor_mtx = cor_cs(0.25, m = 3),
  ind_index = NULL,
  method = "ols",
  alpha = 0.05,
  one_sided = TRUE
  )
#> $power_joint_any
#> [1] 0.9609566
#> 
#> $power_joint_one
#> [1] NA
#> 
#> $power_joint
#> [1] 0.9634129
#> 
#> $power_ind
#> [1] NA
#> 
#> $n1
#> [1] 25
#> 
#> $n2
#> [1] 30
#> 
#> $alpha
#> [1] 0.05
#> 
#> $method
#> [1] "ols"
#> 
#> $one_sided
#> [1] TRUE
#> 

# Generate GST power for 4 endpoints (joint + 3rd endpoint)
obrien_plus(
  n1 = 28,
  n2 = 40,
  es_ind = c(1, 0.25, 0.75, 0.5),
  cor_mtx = cor_cs(0.35, m = 4),
  ind_index = 3,
  method = "ols",
  alpha = 0.05,
  one_sided = TRUE
  )
#> $power_joint_any
#> [1] 0.968545
#> 
#> $power_joint_one
#> [1] 0.9027638
#> 
#> $power_joint
#> [1] 0.9686713
#> 
#> $power_ind
#> [1] 0.9142672
#> 
#> $n1
#> [1] 28
#> 
#> $n2
#> [1] 40
#> 
#> $alpha
#> [1] 0.05
#> 
#> $method
#> [1] "ols"
#> 
#> $one_sided
#> [1] TRUE
#> 
```
