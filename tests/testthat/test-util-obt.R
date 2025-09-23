test_that("example works as expected", {

  dat <- multcomp::mtept
  dat$E4 <- -dat$E4  # align signs for all endpoints
  out <-
    obt(
      data = dat,
      endpoint_vars = c("E1","E2","E3","E4"),
      jendpoint = c("E3", "E4"),
      alpha = 0.05,
      nu = 0.6,
      treatment_vars = "treatment",
      method = "ols"
    )

  expect_equal(
    round(out$alpha_A, 3),
    0.018
  )
  expect_equal(
    names(out),
    c("F", "df", "df_gst", "alpha_A")
  )
})


test_that("endpoint_vars must be named E1, E2, ...", {
  dat <- multcomp::mtept
  dat1 <- setNames(dat, nm = c("treatment", paste0("A", 1:4)))
  expect_error(
    obt(
      data = dat1,
      endpoint_vars = names(dat1)[-1],
      jendpoint = NULL,
      alpha = 0.05,
      nu = 0.6,
      treatment_vars = "treatment",
      method = "ols"
    )
  )
})
