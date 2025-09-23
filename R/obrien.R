#' O’Brien test
#'
#' @param data dataset with treatment and multiple outcomes in wide format
#' @param endpoint_vars the character vectors of outcomes in the dataset dat
#' @param treatment_vars  treatment varialbe in the dataset dat
#' @param method obrien "ols",  "gls" and  "ranksum" test
#' @param var.equal default TRUE. the obrien paper assumes equal variance and using pooled variance to standardize data
#' @param ... other options passed to \code{\link[stats]{t.test}} and \code{\link[stats]{wilcox.test}}
#' @return A list with t-statistic, df, pvalue, alternative, and correlation matrix R
#' @importFrom stats wilcox.test t.test manova residuals cor as.formula sd var
#' @importFrom tibble as_tibble rowid_to_column enframe
#' @importFrom rlang .data :=
#' @examples
#'
#' # prepare example data (from multcomp::mtept)
#' dat <- multcomp::mtept
#' dat$E4 <- -dat$E4  # align signs for all endpoint
#'
#' # OLS method
#' dat |>
#'    obrien(
#'      endpoint_vars = c("E1", "E2", "E3", "E4"),
#'      treatment_vars = "treatment",
#'      method = "ols"
#'      )
#'
#' # GLS one-sided
#' dat |>
#'   obrien(
#'     endpoint_vars = c("E1", "E2", "E3"),
#'     treatment_vars = "treatment",
#'     method = "gls",
#'     alternative = "less"
#'     )
#'
#' # Ranksum method
#' dat |>
#'   obrien(
#'     endpoint_vars = c("E1", "E2", "E3", "E4"),
#'     treatment_vars = "treatment",
#'     method = "ranksum"
#'     )
#'
#' @export
#'
obrien = function(data,
                  endpoint_vars,
                  treatment_vars,
                  method = c("ols", "gls", "ranksum"),
                  var.equal = TRUE,
                  ...){

  trt <- par <- subjid <- val <- val_std <- NULL  # no visible binding notes

  endpt = data %>% dplyr::select(all_of(endpoint_vars))
  group = data %>% dplyr::select(all_of(treatment_vars))

  m = ncol(endpt) # num of endpoint
  n = nrow(endpt) # number of subjects
  k = group %>% pull() %>% unique() %>% length() # number of group

  method = match.arg(method)

  if (m == 1) {

    R <- matrix(1)    # dummy correlation matrix R

    if (method == "ranksum") {
      rlt <-
        wilcox.test(
          formula =  as.formula(paste(endpoint_vars, "~",  treatment_vars)),
          data = data,
          ...
        )
    } else {
      rlt <-
        t.test(
          formula =  as.formula(paste(endpoint_vars, "~",  treatment_vars)),
          var.equal = var.equal,
          data = data,
          ...
        )
    }

  } else{

    # to long data format
    data_long <- data %>%
      rowid_to_column(var = "subjid") %>%
      as_tibble() %>%
      dplyr::select(
        all_of(endpoint_vars),
        {{treatment_vars}},
        "subjid"
      ) %>%
      tidyr::pivot_longer(
        cols = all_of({{endpoint_vars}}),
        values_to = "val",
        names_to = "par"
      ) %>%
      dplyr::rename(
        "trt" := {{treatment_vars}}
      )



    d1 <- data_long %>%
      dplyr::group_by(par, trt) %>%
      dplyr::reframe(
        m = mean(.data$val),
        sd= sd(.data$val),
        var = var(.data$val),
        n = dplyr::n()
      ) %>% # group summaries
      dplyr::group_by(par) %>%
      dplyr::mutate(
        m_p = sum(.data$m * .data$n) / sum(.data$n),                # pool mean
        var_p = sum(.data$var * (.data$n - 1)) / (sum(.data$n) - 2) # pool var
      ) %>%
      dplyr::ungroup()

    rk <- data_long %>%
      group_by(par) %>%
      reframe(
        across(c(subjid, trt), .fns = ~.x),
        rank = rank(val)
      )

    d2 <- data_long %>%
      dplyr::left_join(d1, by = c("par", "trt")) %>%
      dplyr::left_join(rk, by = c("subjid", "par", "trt")) %>%
      dplyr::mutate(
        val_std =  (.data$val - .data$m_p) / sqrt(.data$var_p)
      )

    ## correlation matrix R from MANOVA
    ## but the sample correlation matrix of standardized variable is used in paper
    xsd <- d2 %>%
      tidyr::pivot_wider(
        id_cols = c("subjid", "trt"),
        names_from = par,
        values_from = val_std
        )
    R <-
      manova(
        xsd %>% dplyr::select(all_of(endpoint_vars)) %>% as.matrix() ~ trt,
        data = xsd
      ) %>%
      residuals() %>%
      cor()


    # weight for gls
    w <- solve(R) %>% colSums


    d3 <- d2 %>%
      dplyr::left_join(
        enframe(w, name = "par", value = "weight"),   # avoid potential wrong weight
        by = "par"
        ) %>%
      dplyr::group_by(subjid, trt) %>%
      dplyr::reframe(
        val_std_sum = sum(.data$val_std),
        val_std_wsum = sum(.data$val_std * .data$weight),
        rank_sum = sum(.data$rank)
      )

    # individual t; this part can be used to derive the statistics integrating individual t specified in paper for ols and gls,
    # which is essentially the same
    # tstat = data_long %>%
    #   group_by(par) %>%
    #   nest() %>%
    #   mutate(t_test = map(data,~t.test(val~trt,var.equal = TRUE,data = .)),
    #          t_stat = map_dbl(t_test,"statistic")) %>%
    #   select(par,t_stat)

    # t_ols = sum(tstat$t_stat)/sqrt(sum(R))
    # t_gls = sum(w*tstat$t_stat)/sqrt(sum(solve(R)))


    rlt <-
      switch(
        method,
        ols = t.test(val_std_sum ~ trt, data = d3, var.equal = var.equal, ...),
        gls = t.test(val_std_wsum ~ trt, data = d3, var.equal = var.equal, ...),
        ranksum = t.test(rank_sum ~ trt, data = d3, var.equal = var.equal, ...)
      )

  }

  return(
    list(
      statistic = rlt$statistic,
      df = rlt$parameter,
      pvalue = rlt$p.value,
      alternative = rlt$alternative,
      R = R
    )
  )

}


#' Calculate operational effect size
#' @param lambda vector of effect size for each endpoint
#' @param R correlation matrix of lambda
#' @param method obrien "ols",  "gls"
#' @return A scalar
#' @export
get_oes = function(lambda, R, method = c("ols","gls")) {
  if (length(lambda) != nrow(R))
    stop("the dimension doesn't match")
  J = rep(1, length(lambda))

  method = match.arg(method)
  es =  ifelse(
    method == "ols",
    J %*% lambda / sqrt(J %*% R %*% J),
    J %*% solve(R) %*% lambda / sqrt(J %*% solve(R) %*% J)
  )
  return(es)
}


#' Calculate Power
#' @param oes operational effect size
#' @param n0 sample size in placebo group
#' @param n1 sample size in treatment group
#' @param df degree of freedom
#' @param alpha significance level
#' @importFrom stats qt pt
#' @return power
#' @export
get_power = function(oes, n0, n1 = n0, df = n0 + n1 - 2, alpha = 0.05){
  t_crit = qt(p = 1 - alpha/2, df = df, lower.tail = T) # two sided
  power = 1 - pt(ncp = sqrt(n0 * n1 / (n0 + n1)) * oes,df = df, q = t_crit)
  return(power)
}


#' Calculate Power by simulation
#' @param n0 sample size in placebo group
#' @param n1 sample size in treatment group
#' @param lambda vector of effect size for each endpoint
#' @param R correlation matrix of lambda
#' @param alpha significance level
#' @param N number of replication
#' @param ncore n of cores planned
#' @param method obrien "ols", "gls"
#' @param ... additional arguments passed to \code{\link{obrien}}
#' @return power
#' @export
sim_power = function(n0, n1 = n0, lambda, R, alpha = 0.05, N = 1000, ncore = 4, method = c("ols","gls"), ...){
  method =  match.arg(method)
  f = function(i){
    if(i %% 100 == 0) system(paste0("echo 'Sim Now working:",i,"/",N,"'"))
    m = length(lambda)
    x0 = rmnv(n = n0, mean_v = rep(0, m), cor_mtx = R,treatment = "pcb")
    x1 = rmnv(n = n1, mean_v = lambda,cor_mtx = R,treatment = "trt")
    dat = bind_rows(x0, x1)
    rlt = obrien(dat,endpoint_vars = names(dat)[1:m],treatment_vars = "treatment",method = method,... )
    return(rlt$pvalue)
  }

  rtime = system.time({
    frlt = parallel::mclapply(X = 1:N,FUN = f,mc.cores = ncore)
  })
  print(rtime)

  power = mean( unlist(frlt) <= alpha)
  return(power)
}


#' Calculate sample size
#' @param power target power
#' @param es0 effect size in endpoint 1
#' @param es1 effect size in endpoint 2
#' @param R correlation matrix between endpoints
#' @param alpha significance level
#' @param k sample size ratio of treatment vs placebo
#' @param method obrien "ols",  "gls"
#' @param df_method degrees-of-freedom method (one of: {vd, vob, vlt})
#' @param n0_range range of size in placebo to be searched
#' @param tolerance the desired accuracy (convergence tolerance)
#' @importFrom stats uniroot
#' @return power
#' @export
get_n = function(power, es0, es1, R, alpha = 0.05, k,
                              method = c("ols", "gls"),
                              df_method = c("vd", "vob", "vlt"),
                              n0_range = c(2, 1000), tolerance = 1e-6) {

  method = match.arg(method)
  df_method = match.arg(df_method)

  power_diff = function(n0) {
    n1 = k * n0

    # Calculate degrees of freedom based on the chosen method
    df = switch(df_method,
                "vd" = n0 + n1 - 2,
                "vob" = (n0 + n1 - 4),
                "vlt" = round((n0 + n1 - 2) / 2 * (1 + 1 /4))
    )

    lambda = c(es0, es1)
    oes = get_oes(lambda, R, method)
    calculated_power = get_power(oes, n0, n1, df, alpha)
    return(calculated_power - power)
  }

  result = uniroot(power_diff, lower = n0_range[1], upper = n0_range[2],
                   tol = tolerance)

  n0 = ceiling(result$root)
  n1 = ceiling(k * n0)

  return(list(n0 = n0, n1 = n1))
}
