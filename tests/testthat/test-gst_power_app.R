test_that("gst_power_app() returns a shiny app", {
  expect_equal(
    gst_power_app(runApp = FALSE) |>
      class() |>
      head(1),
    "shiny.appobj"
  )
})
