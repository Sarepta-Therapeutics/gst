test_that("make_forestplot_app() returns a shiny app", {
  expect_equal(
    make_forestplot_app(runApp = FALSE) |>
      class() |>
      head(1),
    "shiny.appobj"
  )
})
