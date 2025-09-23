test_that("obrien() works for OLS", {
  expect_snapshot(
    obrien(
      data = multcomp::mtept,
      endpoint_vars = c("E1", "E2", "E3", "E4"),
      treatment_vars = "treatment",
      method = "ols"
    )
  )
})

test_that("obrien() works for GLS method", {
  expect_snapshot(
    obrien(
      data = multcomp::mtept,
      endpoint_vars = c("E1", "E2", "E3", "E4"),
      treatment_vars = "treatment",
      method = "gls"
    )
  )
})

test_that("obrien() works for Ranksum method", {
  expect_snapshot(
    obrien(
      data = multcomp::mtept,
      endpoint_vars = c("E1", "E2", "E3", "E4"),
      treatment_vars = "treatment",
      method = "ranksum"
    )
  )
})

test_that("obrien() fails when treatment_var has >2 levels", {
  expect_error(obrien(mtcars, endpoint_vars = c("mpg", "hp"), treatment_vars = "cyl"))
})

test_that("obrien() fails when treatment_var has exactly 1 level", {
  expect_error(
    mtcars |>
      dplyr::filter(vs == 1) |>
      obrien(
        endpoint_vars = c("mpg", "hp"),
        treatment_vars = "vs"
      )
  )
})
