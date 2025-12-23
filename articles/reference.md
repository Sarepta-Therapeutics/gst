# Reference for \`gst\` package

## Operational Effect Size

### Ordinary Least Squares (OLS)

$$\Lambda_{OLS} = \mathbf{J}^{T}\lambda/\sqrt{\mathbf{J}^{T}\mathbf{R}\mathbf{J}}\qquad$$$$T_{OLS} = \frac{\mathbf{J}^{T}\mathbf{Z}}{\sqrt{\mathbf{J}^{T}\widehat{\mathbf{R}}\mathbf{J}}} = \frac{\sum\limits_{k = 1}^{m}Z_{k}}{\sqrt{\sum\limits_{k,k\prime = 1}^{m}{\widehat{R}}_{kk\prime}}}$$

### Generalized Least Squares (GLS)

$$\Lambda_{GLS} = \frac{\mathbf{J}^{T}\mathbf{R}^{- 1}\lambda}{\sqrt{\mathbf{J}^{T}\mathbf{R}^{- 1}\mathbf{J}}}$$

$$T_{GLS} = \frac{\mathbf{J}^{T}{\widehat{\mathbf{R}}}^{- 1}\mathbf{Z}}{\sqrt{\mathbf{J}^{T}{\widehat{\mathbf{R}}}^{- 1}\mathbf{J}}}$$

## Type I Error

### Equal $n$ and $df = 2n - 2$

$$Pow(n,\Lambda) = P\left\{ T\left( \sqrt{\frac{n}{2}}\Lambda,2n - 2 \right) > t_{\alpha,2n - 2} \right\}\qquad$$

### General Case

$$Pow(n,\Lambda) = P\left\{ T\left( \sqrt{\frac{n_{0}n_{1}}{n_{0} + n_{1}}}\Lambda,df \right) > t_{\alpha,df} \right\}\qquad$$

Degrees of freedom ($df$):

- Dallow (2008): $n_{0} + n_{1} - 2$

- O’Brien (1984): $n_{0} + n_{1} - 2*m$ ,

- Logan and Tamhane (2004):
  $0.5\left( n_{0} + n_{1} - 2 \right)/\left( 1 + 1/m^{2} \right)$

## P-value Combination

### Fisher’s Method (1932)

Letting $p_{1},p_{2},\ldots,p_{k}$ denote the individual (one- or
two-sided) p-values of the $k$ hypothesis tests to be combined, the test
statistic is then computed with

$$X^{2} = - 2\sum\limits_{i = 1}^{k}\ln\left( p_{i} \right).$$

Under the joint null hypothesis, the test statistic follows a chi-square
distribution with $2k$ degrees of freedom which is used to compute the
combined p-value.

Fisher’s method assumes that the p-values to be combined are
independent. If this is not the case, the method can either be
conservative (not reject often enough) or liberal (reject too often),
depending on the dependence structure among the tests. In this case, one
can adjust the method to account for such dependence (to bring the Type
I error rate closer to some desired nominal significance level).

### Stouffer’s Method (1949)

Letting $p_{1},p_{2},\ldots,p_{k}$ denote the individual (one- or
two-sided) p-values of the $k$ hypothesis tests to be combined, the test
statistic is then computed with

$$z = \sum\limits_{i = 1}^{k}z_{i}/\sqrt{k}$$

where $z_{i} = \Phi^{- 1}\left( 1 - p_{i} \right)$ and
$\Phi^{- 1}( \cdot )$ denotes the inverse of the cumulative distribution
function of a standard normal distribution. Under the joint null
hypothesis, the test statistic follows a standard normal distribution
which is used to compute the combined p-value.

Stouffer’s method assumes that the p-values to be combined are
independent. If this is not the case, the method can either be
conservative (not reject often enough) or liberal (reject too often),
depending on the dependence structure among the tests. In this case, one
can adjust the method to account for such dependence (to bring the Type
I error rate closer to some desired nominal significance level).

### Adjustment of dependence

Adjustment Based on the Effective Number of Tests based on Nyholt, 2004

$$m = 1 + (k - 1)\frac{1 - Var(ev)}{k}$$

where $ev$ is eigenvalues of correlation matrix $R$ among tests, and $k$
is the number of tests

## Reference

[GST White
Paper](https://sarepta.sharepoint.com/:w:/r/sites/Biometrics/Shared%20Documents/Biometrics-Functional-Initiatives/Global-Statistical-Test/SRP%20GST%20White%20Paper%20V1.0.docx?d=w6c16effd0e6e41fd8d201d17a3a27bc9&csf=1&web=1&e=xGzh2g)

Dallow NS, Leonov SL, Roger JH. Practical usage of O’Brien’s OLS and GLS
statistics in clinical trials. Pharm Stat. 2008 Jan-Mar;7(1):53-68. doi:
10.1002/pst.268. PMID: 17390306
