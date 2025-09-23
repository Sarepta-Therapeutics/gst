test_that("forest_reprex() generates a scalar character value", {
  expect_length(
    forest_data() |>
      forest_plot() |>
      forest_reprex(),
    1L
  )
})

test_that("forest_reprex() requires the 'params' attribute to work", {
  xp <- forest_data() |> forest_plot()
  attr(xp, "params") <- NULL
  expect_error(
    xp |> forest_reprex()
  )
})
