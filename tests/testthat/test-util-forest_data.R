test_that("forest_data() looks correct for using with forest_plot()", {
  expect_equal(class(forest_data()), "data.frame")
  expect_type(forest_data(), "list")
  expect_error(forest_data(10))
  expect_identical(forest_data(), forest_data())
  expect_equal(ncol(forest_data()), 9)
})
