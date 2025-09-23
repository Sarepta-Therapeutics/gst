#' O'Brien Plus: Analytical Power for Joint AND Any Individual Endpoint
#'
#' @description
#' This function analytically estimates the statistical power for the scenario where
#' both the O'Brien joint endpoint test is significant AND at least one of the
#' individual endpoints is significant. It also calculates the power for
#' "Joint AND a Specific Individual" (if `ind_index` is provided).
#' It relies on a multivariate t-distribution approximation of the test statistics.
#'
#' @param n1 Numeric, sample size for the first treatment group.
#' @param n2 Numeric, sample size for the second treatment group.
#' @param es_ind Numeric vector, the standardized mean differences (Cohen's d)
#'   for each individual endpoint under the alternative hypothesis.
#' @param cor_mtx Numeric matrix, the correlation matrix (R) among the
#'   standardized individual endpoints.
#' @param ind_index Integer, the 1-based index of a specific individual endpoint
#'   for which "Joint AND Specific Individual" power is also calculated.
#'   Set to NULL if only "Joint AND Any Individual" power is desired.
#' @param method Character, the O'Brien test method to use ("ols" or "gls").
#' @param alpha Numeric, the significance level for each test (e.g., 0.05).
#'   Assumes no explicit multiplicity adjustment for the 'AND' or 'OR' conditions.
#' @param one_sided Logical, default TRUE. If TRUE, a one-sided test is assumed.
#'   If FALSE, a two-sided test is used, with a warning about power interpretation
#'   for positive effect sizes.
#'
#' @examples
#' # Generate GST power for 3 endpoints (joint + any)
#' obrien_plus(
#'   n1 = 25,
#'   n2 = 30,
#'   es_ind = c(1, 0.5, 0.5),
#'   cor_mtx = cor_cs(0.25, m = 3),
#'   ind_index = NULL,
#'   method = "ols",
#'   alpha = 0.05,
#'   one_sided = TRUE
#'   )
#'
#' # Generate GST power for 4 endpoints (joint + 3rd endpoint)
#' obrien_plus(
#'   n1 = 28,
#'   n2 = 40,
#'   es_ind = c(1, 0.25, 0.75, 0.5),
#'   cor_mtx = cor_cs(0.35, m = 4),
#'   ind_index = 3,
#'   method = "ols",
#'   alpha = 0.05,
#'   one_sided = TRUE
#'   )
#'
#' @returns
#' a named list containing computation settings and results, including:
#' - `power_joint_any` - power for joint endpoints and any additional endpoint
#' - `power_joint_one` - power for joint endpoints and a specific endpoint (specified by `ind_index`)
#' - `power_joint` - power for the joint endpoint test
#' - `power_ind` - power for the specific endpoint (specified by `ind_index`)
#' - `n1` - sample size for the first treatment group
#' - `n2` - sample size for the second treatment group
#' - `alpha` - significance level
#' - `method` - the O'Brien test method used
#' - `one_sided` - logical indicating if the test is one-sided
#'
#' @export
#'
obrien_plus = function(n1,
                       n2 = n1,
                       df = n1 + n2 - 2,
                       es_ind,
                       cor_mtx,
                       ind_index = NULL,
                       method = c("ols", "gls"),
                       alpha = 0.025,
                       one_sided = TRUE) {

  method = match.arg(method)
  m = length(es_ind) # Number of endpoints

  if (m != nrow(cor_mtx) || m != ncol(cor_mtx)) {
    stop("Dimensions of 'es_ind' and 'cor_mtx' do not match.")
  }

  sqrt_n_factor = sqrt((n1 * n2) / (n1 + n2))

  # Non-centrality parameter for O'Brien test
  if (method == "ols") {
    ncp_obrien = sum(es_ind) / sqrt(sum(cor_mtx)) * sqrt_n_factor
  } else { # gls
    # Calculate GLS weights once
    wt = colSums(solve(cor_mtx))
    ncp_obrien = (wt %*% es_ind) / sqrt(wt %*% cor_mtx %*% wt) * sqrt_n_factor
  }

  # Critical value for t-distribution
  if (one_sided) {
    z_crit = qt(1 - alpha, df = df) # Use qt for t-distribution, qnorm if norm
  } else {
    z_crit = qt(1 - alpha / 2, df = df)
  }

  # Warning for two-sided power interpretation with positive effects
  if (!one_sided) {
    warning(
      "For two-sided tests, power calculation here assumes rejection occurs primarily in the upper tail based on positive 'es_ind'.\n
       For mixed or negative effects, or if non-directional rejection is equally likely in both tails, this might not be accurate and a more complex calculation or simulation is needed."
    )
  }

  # --- Individual Powers ---
  if (one_sided) {
    power_joint = pt(z_crit, df = df, ncp = ncp_obrien, lower.tail = FALSE) # Use pt for t-distribution
    ncp_all_ind <- es_ind * sqrt_n_factor # NCPs for all individual endpoints
    power_ind <- if (!is.null(ind_index)) pt(z_crit, df = df, ncp = ncp_all_ind[ind_index], lower.tail = FALSE) else NA # Use pt，we can use pnorm for large sample size
  } else {
    power_joint = pt(z_crit, df = df, ncp = ncp_obrien, lower.tail = FALSE) + pt(-z_crit, df = df, ncp = ncp_obrien, lower.tail = TRUE)
    ncp_all_ind <- es_ind * sqrt_n_factor
    power_ind <- if (!is.null(ind_index)) (pt(z_crit, df = df, ncp = ncp_all_ind[ind_index], lower.tail = FALSE) + pt(-z_crit, df = df, ncp = ncp_all_ind[ind_index], lower.tail = TRUE)) else NA # Use pt
  }

  # --- Power for Joint AND Specific Individual ---
  power_joint_one <- NA
  if (!is.null(ind_index)) {
    ncp_ind_specific = es_ind[ind_index] * sqrt_n_factor

    # Correlation between O'Brien test statistic and specific individual test statistic
    if (method == "ols") {
      rho_oi_specific = sum(cor_mtx[, ind_index]) / sqrt(sum(cor_mtx))
    } else { # gls
      wt = colSums(solve(cor_mtx))
      rho_oi_specific = (wt %*% cor_mtx[, ind_index]) / sqrt(wt %*% cor_mtx %*% wt)
    }
    rho_oi_specific = max(min(rho_oi_specific, 1), -1)

    mu_alt_specific <- c(ncp_obrien, ncp_ind_specific)
    sigma_alt_specific <- matrix(c(1, rho_oi_specific, rho_oi_specific, 1), nrow = 2, byrow = TRUE)

    power_joint_one <- mvtnorm::pmvt( # Use pmvt
      lower = c(z_crit, z_crit),
      upper = c(Inf, Inf),
      delta = mu_alt_specific, # 'mean' in pmvnorm, 'delta' in pmvt
      sigma = sigma_alt_specific,
      df = df
    )[1]
  }

  # --- Power for Joint AND Any One Individual ---

  # Mean vector for (O'Brien, Ind_1, ..., Ind_m)
  mu_full_alt <- c(ncp_obrien, ncp_all_ind)

  # Full correlation matrix for (O'Brien, Ind_1, ..., Ind_m) test statistics
  # Initialize a (m+1) x (m+1) identity matrix
  sigma_full_alt <- diag(m + 1)

  # Fill in correlations between O'Brien test and each individual test
  for (k in 1:m) {
    if (method == "ols") {
      rho_0k = sum(cor_mtx[, k]) / sqrt(sum(cor_mtx))
    } else { # gls
      wt = colSums(solve(cor_mtx)) # ensure wt is defined
      rho_0k = (wt %*% cor_mtx[, k]) / sqrt(wt %*% cor_mtx %*% wt)
    }
    rho_0k = max(min(rho_0k, 1), -1) # Ensure valid correlation
    sigma_full_alt[1, k + 1] <- rho_0k
    sigma_full_alt[k + 1, 1] <- rho_0k
  }

  # Fill in correlations between individual tests (direct from cor_mtx)
  sigma_full_alt[2:(m + 1), 2:(m + 1)] <- cor_mtx

  # Calculate P(T_J > c_J AND all T_k <= c_k) using pmvt
  power_no_sig <- mvtnorm::pmvt( # Use pmvt
    lower = c(z_crit, rep(-Inf, m)), # O'Brien > z_crit, Ind_k no lower bound
    upper = c(Inf, rep(z_crit, m)),   # O'Brien Inf, Ind_k <= z_crit
    delta = mu_full_alt, # 'mean' in pmvnorm, 'delta' in pmvt
    sigma = sigma_full_alt,
    df = df
  )[1]

  # Power for "Joint AND Any One Individual" (overall)
  # P(A AND (B1 OR ... OR Bm)) = P(A) - P(A AND NOT(B1 OR ... AND NOT Bm))
  power_joint_any <- power_joint - power_no_sig

  # Ensure power is within [0,1] due to numerical approximations
  power_joint_any <- max(0, min(1, power_joint_any))


  return(
    list(
      power_joint_any = power_joint_any,
      power_joint_one = power_joint_one,
      power_joint = power_joint,
      power_ind = power_ind,
      n1 = n1,
      n2 = n2,
      alpha = alpha,
      method = method,
      one_sided = one_sided
    )
  )
}
