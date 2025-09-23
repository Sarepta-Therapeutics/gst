
#' Perform Obrien truncated closed testing
#'
#' @param data input data; columns should contain endpoint data and must be named E1, E2
#' @param endpoint_vars vector of endpoint column names (character/vector)
#' @param jendpoint joint endpoint, a vector of individual endpoints (character/vector)
#' @param treatment_vars treatment column name (character/scalar)
#' @param alpha significance level (numeric/scalar)
#' @param nu truncation parameter, between 0 and 1 (numeric/scalar; default = 0.8)
#' @param method estimation method (character/scalar; default = 'OLS')
#' @param var.equal assume equal variances? (logical/scalar; default = TRUE)
#' @param ... additional arguments passed to \code{\link{obrien}}
#'
#' @returns a list containing the following elements:
#' - `F`: target family of hypotheses (character/vector)
#' - `df`: data.frame with relevant hypotheses and parameters
#' - `df_gst`: data.frame with results from the different procedures
#' - `alpha_A`: unused alpha available for propagation to the next family
#'
#' @examples
#' dat <- multcomp::mtept
#' dat$E4 <- -dat$E4  # align signs for all endpoints
#' obt(
#'     data = dat,
#'     endpoint_vars = c("E1","E2","E3","E4"),
#'     jendpoint = c("E3", "E4"),
#'     alpha = 0.05,
#'     nu = 0.6,
#'     treatment_vars = "treatment",
#'     method = "ols"
#' )
#'
#' @section Input Data Requirements:
#' The endpoint variables in `data` must be named `E1`, `E2`, `E3`, etc. for
#' the function to work correctly.  If you endpoint columns do not have this
#' naming convention, you must rename them.
#'
#' @note This is the truncated closed test as proposed by:
#' Luo, X., Li, L., Savenkov, O., Liu, W., Ni, X., Tang, W. and Guo, W., 2025.
#' Multiple Comparisons Procedures for Analyses of Joint Primary Endpoints and
#' Secondary Endpoints. Pharmaceutical Statistics, 24(3), p.e70010
#'
#' @export
#'
obt = function(data,
               endpoint_vars,
               jendpoint = NULL,
               treatment_vars,
               alpha = 0.05,
               nu = 0.8,
               method = c("ols", "gls", "ranksum"),
               var.equal = TRUE,
               ...){


  # Check inputs
  if (!is.data.frame(data))
    stop("Input `data` must be a data.frame.")
  if (!is.element(treatment_vars, names(data)))
    stop("`treatment_vars` must be a column within `data`!")
  # -- if `endpoint_vars` is NULL, grab column names from `data`
  if (is.null(endpoint_vars))
    endpoint_vars <- setdiff(names(data), treatment_vars)
  # -- `endpoint_vars` must be named E1, E2, ...
  if (any(stringr::str_sub(endpoint_vars, 1, 1) != "E"))
    stop("`endpoint_vars` must be {E1, E2, ...}")

  # Create hypotheses from endpoint variables (E1 --> H1; E6 --> H6)
  hypotheses <- gsub("^E", "H", endpoint_vars)

  # Derive F
  if (length(jendpoint) > 0) {
    F <- c("G", hypotheses)
  } else {
    F <- hypotheses
  }

  # Generate all possible combinations of elements in F
  all_Fs <- list()
  for (k in 1:length(F)) {
    comb_k <- utils::combn(F, k, simplify = FALSE)
    all_Fs <- c(all_Fs, comb_k)
  }

  # Derive local pvalues
  df <-
    purrr::map_df(
      all_Fs,
      function(fs) {
        # -- replace joint hypothesis (G) with individual hypotheses (H)
        new_x <- unlist(lapply(fs, function(e) {
          if (e == "G") gsub("^E", "H", jendpoint) else e })
        )
        new_x <- unique(new_x)
        Es <- gsub("^H", "E", new_x)  # get endpoints corresponding to each hypothesis
        results <-
          obrien(
            data = data,
            endpoint_vars = Es,
            treatment_vars = treatment_vars,
            method = method,
            var.equal = var.equal,
            ...
          )
        dplyr::tibble(
          all_Fs = paste(fs, collapse = "&"),
          all_Fs2 = paste(new_x, collapse = "&"),
          all_ps = results[["pvalue"]]
        )
      }
    )


  # TODO: we are counting H1&H2 and H2&H1 as 2 separate hypotheses
  #   --> hotfix: sort before paste/collapsing
  n_hs <- nrow(df)
  n_uhs <- length(unique(df$all_Fs2))
  message(paste("Number of intersection hypotheses:", n_hs))
  message(paste("Number of unique intersection hypotheses:", n_uhs))

  # Combine results across all combinations of hypotheses
  df <- df |>
    dplyr::mutate(
      nu = nu,
      zeta = stringr::str_count(.data$all_Fs2, "H") / length(F),   # proportion of hypotheses being tested for each intersection
      alpha_trun = nu * alpha + (1 - nu) * .data$zeta * alpha      # local alpha threshold from the truncated closed test
    )

  # Rejection status for truncated & untruncated closed testing (1 = reject; 0 = accept)
  df_gst <-
    purrr::map_df(
      F,
      function(fk) {
        df |>
          dplyr::filter(
            grepl(fk, all_Fs)
          ) |>
          dplyr::mutate(
            rej = as.numeric(.data$all_ps <= alpha),
            rejt = as.numeric(.data$all_ps <= .data$alpha_trun)
          ) |>
          dplyr::summarize(
            F = fk,
            rej_ob = min(.data$rej),
            rej_obt = min(.data$rejt)
          )
      }
    )

  # Compute adjusted p-values for F
  p <- df[df$all_Fs %in% F, ]$all_ps
  methods <- c("holm", "hochberg", "hommel", "bonferroni")
  for (m in methods) {
    p_adj <- stats::p.adjust(p, method = m, n = length(p))
    df_gst[[m]] <- ifelse(p_adj <= alpha, 1, 0)
  }

  # Compute unused alpha (for propagation to the next family)
  A <- df_gst[df_gst$rej_obt == 0, ]$F
  new_A <- unlist(lapply(A, function(e) {
    if (e == "G") gsub("^E", "H", jendpoint) else e })
  )
  new_A <- unique(new_A)
  zeta_A <- length(new_A) / n_uhs
  alpha_A <- alpha * (1 - nu) * (1 - zeta_A)

  return(
    list(
      F = F,
      df = df,
      df_gst = df_gst,
      alpha_A = alpha_A
    )
  )

}
