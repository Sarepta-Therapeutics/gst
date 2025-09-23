
#' Simulate from a Multivariate Normal Distribution
#'
#' @param n number of samples
#' @param mean_v vector of means
#' @param cor_mtx correlation matrix for input variables
#' @param treatment treatment column value (character/scalar)
#' @param ... additional parameters passed to \code{\link[MASS]{mvrnorm}}
#'
rmnv <- function(n, mean_v, cor_mtx, treatment = "trt", ...) {
  MASS::mvrnorm(
    n = n,
    mu = mean_v,
    Sigma = cor_mtx,
    ...
  ) %>%
    data.frame() %>%
    mutate(
      treatment = treatment
    )
}


#' Create a compound-symmetric correlation matrix
#'
#' @param r rho, correlation coefficient (numeric/scalar)
#' @param m number of rows/columns (numeric/scalar)
#'
#' @export
#'
cor_cs <- function(r, m = 2){
  x <- matrix(r, m, m)
  diag(x) <- 1
  return(x)
}

#' P-value combination method
#'
#' @param p p-values (numeric/vector)
#' @param R correlation matrix
#' @param method choose between 'fisher' or 'stouffer' methods
#'
#' @importFrom stats pchisq pnorm qnorm
p_combine <- function(p, R, method = c("fisher","stouffer")){
  method = match.arg(method)

  k = length(p)
  evs = base::eigen(R)$values

  # # effective number of tests (based on Nyholt, 2004)
  m = 1 + (k - 1) * (1 - var(evs) / k)


  if (method == "fisher") {
    statistic = -2 * sum(log(p))* (m / k)
    pval = pchisq(statistic, df = 2 * m, lower.tail = FALSE)
  }
  if (method == "stouffer") {
    statistic = sum(qnorm(p, lower.tail = FALSE)) / sqrt(k) * sqrt(m / k)
    pval = pnorm(statistic, lower.tail = FALSE)
  }

  return(pval)
}
