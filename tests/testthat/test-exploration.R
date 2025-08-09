# tests/testthat/test-exploration.R
test_that("explore_cdm works with valid CDM", {
  skip_on_cran()
  skip_if_not_installed("CDMConnector")
  
  cdm_setup <- setup_omop_cdm_eunomia(verbose = FALSE)
  
  expect_message(
    stats <- explore_cdm(cdm_setup$cdm, verbose = TRUE),
    "CDM Exploration"
  )
  
  # Check return structure
  expect_true(is.list(stats))
  expect_true("total_persons" %in% names(stats))
  expect_true("gender_distribution" %in% names(stats))
  expect_true("age_statistics" %in% names(stats))
  
  # Check values are reasonable
  expect_gt(stats$total_persons, 0)
  expect_true(is.data.frame(stats$gender_distribution))
  expect_true(is.data.frame(stats$age_statistics))
  
  CDMConnector::cdmDisconnect(cdm_setup$cdm)
})

test_that("plot_cdm_demographics creates valid plot", {
  skip_on_cran()
  skip_if_not_installed("CDMConnector")
  skip_if_not_installed("ggplot2")
  
  cdm_setup <- setup_omop_cdm_eunomia(verbose = FALSE)
  
  plot <- plot_cdm_demographics(cdm_setup$cdm)
  
  expect_true("ggplot" %in% class(plot))
  expect_true(!is.null(plot$data))
  expect_true(nrow(plot$data) > 0)
  
  CDMConnector::cdmDisconnect(cdm_setup$cdm)
})

test_that("exploration functions validate inputs", {
  expect_error(
    explore_cdm("not_a_cdm"),
    "cdm must be a CDM reference object"
  )
  
  expect_error(
    plot_cdm_demographics("not_a_cdm"),
    "cdm must be a CDM reference object"
  )
})