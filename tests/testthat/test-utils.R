# tests/testthat/test-utils.R
test_that("get_available_datasets returns valid data", {
  datasets <- get_available_datasets()
  
  expect_true(is.data.frame(datasets))
  expect_true("dataset_name" %in% names(datasets))
  expect_true("description" %in% names(datasets))
  expect_gt(nrow(datasets), 0)
  expect_true("GiBleed" %in% datasets$dataset_name)
})

test_that("check_and_install_packages works", {
  # Test with packages that should already be installed
  result <- check_and_install_packages(c("base", "utils"), quietly = TRUE)
  
  expect_true(is.logical(result))
  expect_true(all(result))
  expect_equal(names(result), c("base", "utils"))
})