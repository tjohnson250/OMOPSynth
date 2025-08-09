# tests/testthat/test-synthetic_data.R
test_that("create_synthetic_omop_data creates valid database", {
  # Test with small dataset
  db <- create_synthetic_omop_data(
    n_patients = 10,
    verbose = FALSE
  )
  
  # Check connection is valid
  expect_true(DBI::dbIsValid(db))
  
  # Check tables were created
  tables <- DBI::dbListTables(db)
  expected_tables <- c("person", "observation_period", "visit_occurrence", 
                       "condition_occurrence", "drug_exposure")
  expect_true(all(expected_tables %in% tables))
  
  # Check person table has correct number of rows
  person_count <- DBI::dbGetQuery(db, "SELECT COUNT(*) as count FROM person")
  expect_equal(person_count$count, 10)
  
  # Check referential integrity
  person_ids <- DBI::dbGetQuery(db, "SELECT DISTINCT person_id FROM person")$person_id
  obs_period_ids <- DBI::dbGetQuery(db, "SELECT DISTINCT person_id FROM observation_period")$person_id
  expect_true(all(obs_period_ids %in% person_ids))
  
  # Clean up
  DBI::dbDisconnect(db)
})

test_that("create_synthetic_omop_data validates inputs", {
  expect_error(
    create_synthetic_omop_data(n_patients = 0),
    "n_patients must be a positive integer"
  )
  
  expect_error(
    create_synthetic_omop_data(start_year = 2000, end_year = 1990),
    "start_year must be less than end_year"
  )
})

test_that("synthetic data has realistic structure", {
  db <- create_synthetic_omop_data(n_patients = 100, verbose = FALSE)
  
  # Check person demographics
  gender_dist <- DBI::dbGetQuery(db, 
                                 "SELECT gender_concept_id, COUNT(*) as count FROM person GROUP BY gender_concept_id")
  expect_true(nrow(gender_dist) >= 1)
  expect_true(all(gender_dist$gender_concept_id %in% c(8507, 8532)))
  
  # Check visits exist
  visit_count <- DBI::dbGetQuery(db, "SELECT COUNT(*) as count FROM visit_occurrence")
  expect_gt(visit_count$count, 0)
  
  DBI::dbDisconnect(db)
})