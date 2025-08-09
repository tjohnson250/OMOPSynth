# tests/testthat/test-setup_eunomia.R
test_that("setup_omop_cdm_eunomia works with default parameters", {
  skip_on_cran()
  skip_if_not_installed("CDMConnector")
  skip_if_not_installed("duckdb")
  
  # Test basic setup
  expect_message(
    cdm_setup <- setup_omop_cdm_eunomia(verbose = TRUE),
    "Setting up OMOP CDM"
  )
  
  # Check that we got a valid CDM object
  expect_true("cdm_reference" %in% class(cdm_setup$cdm))
  expect_true("duckdb_connection" %in% class(cdm_setup$connection))
  
  # Check basic tables exist
  expect_true("person" %in% names(cdm_setup$cdm))
  expect_true("visit_occurrence" %in% names(cdm_setup$cdm))
  
  # Clean up
  CDMConnector::cdmDisconnect(cdm_setup$cdm)
})

test_that("setup_omop_cdm_eunomia validates inputs", {
  expect_error(
    setup_omop_cdm_eunomia("invalid_dataset"),
    "Invalid dataset_name"
  )
  
  expect_error(
    setup_omop_cdm_eunomia("GiBleed", "invalid_version"),
    "cdm_version must be"
  )
})

test_that("setup_omop_cdm_eunomia_direct works", {
  skip_on_cran()
  skip_if_not_installed("Eunomia")
  skip_if_not_installed("DatabaseConnector")
  
  expect_message(
    conn_setup <- setup_omop_cdm_eunomia_direct(verbose = TRUE),
    "Setting up OMOP CDM using Eunomia"
  )
  
  expect_true(!is.null(conn_setup$connection))
  expect_true(!is.null(conn_setup$connectionDetails))
  
  # Clean up
  DatabaseConnector::disconnect(conn_setup$connection)
})
