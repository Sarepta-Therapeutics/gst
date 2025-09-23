test_that("forest_plot() generates a forestplot object", {
  expect_equal(
    forest_data() |>
      forest_plot() |>
      class() |>
      head(1),
    "forestplot"
  )
})

test_that("forest_plot() does not work with incorrect input data", {
  expect_error(forest_plot())
  expect_error(data.frame(a = 1:10, b = 1:10) |> forest_plot())
  expect_error(c(1:10) |> forest_plot())
})

test_that("forest_plot() returns required attributes", {
  expect_contains(
    forest_data() |>
      forest_plot() |>
      attributes() |>
      names(),
    c("dims")
  )
})

test_that("forest_plot() works with custom columns and custom widths", {
  expect_equal(
    forest_data() |>
      forest_plot(
        display_cols = c("Group", "forest", "est+ci", "p"),
        display_widths = c(0.2, 0.4, 0.2, 0.2)
      ) |>
      class() |>
      head(1),
    "forestplot"
  )
})

test_that("forest_plot() works with custom columns only (no custom widths)", {
  expect_equal(
    forest_data() |>
      forest_plot(
        display_cols = c("Group", "forest", "est+ci", "p")
      ) |>
      class() |>
      head(1),
    "forestplot"
  )
})

test_that("forest_plot() works with custom width only (no custom columns)", {
  expect_equal(
    forest_data() |>
      forest_plot(
        display_widths = c(0.15, 0.1, 0.1, 0.25, 0.2, 0.1)
      ) |>
      class() |>
      head(1),
    "forestplot"
  )
})

test_that("forest_plot() works with extra columns", {
  expect_equal(
    forest_data() |>
      dplyr::mutate(
        Extra = "abc"
      ) |>
      forest_plot(
        display_cols = c("Group", "forest", "est+ci", "p", "Extra"),
        display_widths = c(0.15, 0.3, 0.15, 0.1, 0.1)
      ) |>
      class() |>
      head(1),
    "forestplot"
  )
})

test_that("forest_plot() fails when incorrect columns specified", {
  expect_error(
    forest_data() |>
      forest_plot(
        display_cols = c("Groupzzz", "forest", "est+ci", "p"),
        display_widths = c(0.2, 0.4, 0.2, 0.2)
      )
  )
})

test_that("forest_plot() custom x-tick marks must be a numeric vector", {
  expect_error(
    forest_data() |>
      forest_plot(
        plot_x_ticks = c(-1, 0, 1, "a")
      )
  )
})

test_that("forest_plot() custom 'digits' param must be a scalar whole number (or NULL)", {
  expect_error(
    forest_data() |> forest_plot(digits = -1)
  )
  expect_error(
    forest_data() |> forest_plot(digits = 1:5)
  )
  expect_error(
    forest_data() |> forest_plot(digits = 1.55)
  )
  expect_equal(
    forest_data() |> forest_plot(digits = 2) |> class() |> head(1),
    "forestplot"
  )
  expect_equal(
    forest_data() |> forest_plot(digits = NULL) |> class() |> head(1),
    "forestplot"
  )
})

test_that("forest_plot() works for symmetric and non-symmetric axes", {
  expect_equal(
    forest_data() |> forest_plot(plot_symmetric = TRUE) |> class() |> head(1),
    "forestplot"
  )
  expect_equal(
    forest_data() |> forest_plot(plot_symmetric = FALSE) |> class() |> head(1),
    "forestplot"
  )
})

test_that("forest_plot() works when adjusting arrow labels", {
  expect_equal(
    forest_data() |>
      forest_plot(
        arrow_prefix = NULL,
        arrow_label_left = "Left",
        arrow_label_right = "Right"
        ) |>
      class() |>
      head(1),
    "forestplot"
  )
  expect_equal(
    forest_data() |>
      forest_plot(
        arrow_prefix = "Not",
        arrow_label_left = "Left",
        arrow_label_right = "Right",
        flip_arrows = TRUE
        ) |>
      class() |>
      head(1),
    "forestplot"
  )
})
