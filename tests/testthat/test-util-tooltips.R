test_that("icon functions work", {
  expect_equal(
    alert_icon() |> class(),
    c("html", "character")
  )
  expect_equal(
    info_icon() |> class(),
    c("html", "character")
  )
})

test_that("tooltip_label() needs a 'label' argument", {
  expect_error(
    tooltip_label()
  )
  expect_error(
    tooltip_label(info = "some info")
  )
})

test_that("tooltip_label() can have info or alert tooltips, or both", {
  expect_equal(
    tooltip_label("hi", info = "info") |> class(),
    "shiny.tag"
  )
  expect_equal(
    tooltip_label("hi", alert = "alert") |> class(),
    "shiny.tag"
  )
  expect_equal(
    tooltip_label("hi", info = "info", alert = "alert") |> class(),
    "shiny.tag"
  )
})
