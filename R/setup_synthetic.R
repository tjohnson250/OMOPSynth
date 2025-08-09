#' Create Synthetic OMOP CDM Data
#'
#' Generates completely synthetic OMOP Common Data Model data in an in-memory 
#' SQLite database. This function creates realistic but artificial healthcare 
#' data following OMOP CDM table structures and relationships.
#'
#' @param n_patients Integer specifying the number of synthetic patients to 
#'   generate. Default is 1000.
#' @param seed Integer for random seed to ensure reproducible data generation. 
#'   Default is 123.
#' @param start_year Integer specifying the earliest birth year for patients. 
#'   Default is 1920.
#' @param end_year Integer specifying the latest birth year for patients. 
#'   Default is 2005.
#' @param avg_visits_per_patient Numeric specifying average number of visits 
#'   per patient. Default is 3.
#' @param avg_conditions_per_patient Numeric specifying average number of 
#'   conditions per patient. Default is 2.
#' @param avg_drugs_per_patient Numeric specifying average number of drug 
#'   exposures per patient. Default is 4.
#' @param verbose Logical indicating whether to print progress messages. 
#'   Default is TRUE.
#'
#' @return A DBI connection object to the in-memory SQLite database containing 
#'   the synthetic OMOP CDM data.
#'
#' @details
#' The function creates the following OMOP CDM tables with synthetic data:
#' \itemize{
#'   \item person - Patient demographics including gender, birth date, race, ethnicity
#'   \item observation_period - Time periods during which patients are observed
#'   \item visit_occurrence - Healthcare visits (inpatient, outpatient, emergency, etc.)
#'   \item condition_occurrence - Diagnosed medical conditions
#'   \item drug_exposure - Medication prescriptions and administrations
#' }
#'
#' The synthetic data maintains referential integrity between tables and uses 
#' realistic concept IDs from the OMOP vocabulary where possible. However, 
#' this is simplified synthetic data and may not include all OMOP CDM tables 
#' or the complete vocabulary.
#'
#' For more realistic and complete synthetic data, consider using the Eunomia 
#' datasets via \code{\link{setup_omop_cdm_eunomia}}.
#'
#' @examples
#' \dontrun{
#' # Create synthetic data for 500 patients
#' synthetic_db <- create_synthetic_omop_data(n_patients = 500)
#' 
#' # Query the synthetic data
#' person_count <- DBI::dbGetQuery(synthetic_db, 
#'                                "SELECT COUNT(*) as count FROM person")
#' print(person_count)
#' 
#' # List all tables
#' tables <- DBI::dbListTables(synthetic_db)
#' print(tables)
#' 
#' # Clean up
#' DBI::dbDisconnect(synthetic_db)
#' }
#'
#' @seealso \code{\link{setup_omop_cdm_eunomia}}, \code{\link{explore_cdm}}
#'
#' @export
#' @importFrom DBI dbConnect dbWriteTable dbListTables
#' @importFrom RSQLite SQLite
create_synthetic_omop_data <- function(n_patients = 1000,
                                       seed = 123,
                                       start_year = 1920,
                                       end_year = 2005,
                                       avg_visits_per_patient = 3,
                                       avg_conditions_per_patient = 2,
                                       avg_drugs_per_patient = 4,
                                       verbose = TRUE) {
  
  # Validate inputs
  if (n_patients <= 0) {
    stop("n_patients must be a positive integer")
  }
  
  if (start_year >= end_year) {
    stop("start_year must be less than end_year")
  }
  
  if (verbose) {
    message("Creating synthetic OMOP CDM data for ", n_patients, " patients")
  }
  
  # Create in-memory SQLite database
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  
  # Set seed for reproducible data
  set.seed(seed)
  
  # Create Person table
  if (verbose) message("Creating person table...")
  person <- .create_person_table(n_patients, start_year, end_year)
  
  # Create Observation Period table
  if (verbose) message("Creating observation_period table...")
  observation_period <- .create_observation_period_table(n_patients)
  
  # Create Visit Occurrence table
  n_visits <- round(n_patients * avg_visits_per_patient)
  if (verbose) message("Creating visit_occurrence table (", n_visits, " visits)...")
  visit_occurrence <- .create_visit_occurrence_table(n_visits, n_patients)
  
  # Create Condition Occurrence table
  n_conditions <- round(n_patients * avg_conditions_per_patient)
  if (verbose) message("Creating condition_occurrence table (", n_conditions, " conditions)...")
  condition_occurrence <- .create_condition_occurrence_table(n_conditions, n_patients, n_visits)
  
  # Create Drug Exposure table
  n_drugs <- round(n_patients * avg_drugs_per_patient)
  if (verbose) message("Creating drug_exposure table (", n_drugs, " exposures)...")
  drug_exposure <- .create_drug_exposure_table(n_drugs, n_patients, n_visits)
  
  # Write tables to database
  if (verbose) message("Writing tables to database...")
  DBI::dbWriteTable(con, "person", person, overwrite = TRUE)
  DBI::dbWriteTable(con, "observation_period", observation_period, overwrite = TRUE)
  DBI::dbWriteTable(con, "visit_occurrence", visit_occurrence, overwrite = TRUE)
  DBI::dbWriteTable(con, "condition_occurrence", condition_occurrence, overwrite = TRUE)
  DBI::dbWriteTable(con, "drug_exposure", drug_exposure, overwrite = TRUE)
  
  if (verbose) {
    message("Synthetic OMOP CDM tables created successfully!")
    tables <- DBI::dbListTables(con)
    message("Available tables: ", paste(tables, collapse = ", "))
  }
  
  return(con)
}

# Internal helper functions for creating synthetic data tables

.create_person_table <- function(n_patients, start_year, end_year) {
  data.frame(
    person_id = 1:n_patients,
    gender_concept_id = sample(c(8507, 8532), n_patients, replace = TRUE), # Male/Female
    year_of_birth = sample(start_year:end_year, n_patients, replace = TRUE),
    month_of_birth = sample(1:12, n_patients, replace = TRUE),
    day_of_birth = sample(1:28, n_patients, replace = TRUE),
    birth_datetime = as.POSIXct(paste(
      sample(start_year:end_year, n_patients, replace = TRUE),
      sample(1:12, n_patients, replace = TRUE),
      sample(1:28, n_patients, replace = TRUE)
    ), format = "%Y %m %d"),
    race_concept_id = sample(c(8515, 8516, 8527, 8557), n_patients, replace = TRUE),
    ethnicity_concept_id = sample(c(38003563, 38003564), n_patients, replace = TRUE),
    location_id = sample(1:100, n_patients, replace = TRUE),
    provider_id = sample(1:50, n_patients, replace = TRUE),
    care_site_id = sample(1:20, n_patients, replace = TRUE),
    person_source_value = paste0("P", sprintf("%06d", 1:n_patients)),
    gender_source_value = sample(c("M", "F"), n_patients, replace = TRUE),
    gender_source_concept_id = 0,
    race_source_value = sample(c("White", "Black", "Asian", "Other"), n_patients, replace = TRUE),
    race_source_concept_id = 0,
    ethnicity_source_value = sample(c("Hispanic", "Not Hispanic"), n_patients, replace = TRUE),
    ethnicity_source_concept_id = 0,
    stringsAsFactors = FALSE
  )
}

.create_observation_period_table <- function(n_patients) {
  data.frame(
    observation_period_id = 1:n_patients,
    person_id = 1:n_patients,
    observation_period_start_date = as.Date("2010-01-01") + sample(0:365, n_patients, replace = TRUE),
    observation_period_end_date = as.Date("2023-12-31"),
    period_type_concept_id = 44814724,
    stringsAsFactors = FALSE
  )
}

.create_visit_occurrence_table <- function(n_visits, n_patients) {
  data.frame(
    visit_occurrence_id = 1:n_visits,
    person_id = sample(1:n_patients, n_visits, replace = TRUE),
    visit_concept_id = sample(c(9201, 9202, 9203, 262), n_visits, replace = TRUE), # Different visit types
    visit_start_date = as.Date("2010-01-01") + sample(0:(365*13), n_visits, replace = TRUE),
    visit_start_datetime = as.POSIXct("2010-01-01") + sample(0:(365*13*24*3600), n_visits, replace = TRUE),
    visit_end_date = as.Date("2010-01-01") + sample(0:(365*13), n_visits, replace = TRUE),
    visit_end_datetime = as.POSIXct("2010-01-01") + sample(0:(365*13*24*3600), n_visits, replace = TRUE),
    visit_type_concept_id = 44818517,
    provider_id = sample(1:50, n_visits, replace = TRUE),
    care_site_id = sample(1:20, n_visits, replace = TRUE),
    visit_source_value = paste0("V", sprintf("%08d", 1:n_visits)),
    visit_source_concept_id = 0,
    admitted_from_concept_id = 0,
    admitted_from_source_value = "",
    discharged_to_concept_id = 0,
    discharged_to_source_value = "",
    preceding_visit_occurrence_id = as.integer(NA),
    stringsAsFactors = FALSE
  )
}

.create_condition_occurrence_table <- function(n_conditions, n_patients, n_visits) {
  data.frame(
    condition_occurrence_id = 1:n_conditions,
    person_id = sample(1:n_patients, n_conditions, replace = TRUE),
    condition_concept_id = sample(c(201820, 141932, 372906, 4329847), n_conditions, replace = TRUE), # Common conditions
    condition_start_date = as.Date("2010-01-01") + sample(0:(365*13), n_conditions, replace = TRUE),
    condition_start_datetime = as.POSIXct("2010-01-01") + sample(0:(365*13*24*3600), n_conditions, replace = TRUE),
    condition_end_date = as.Date("2010-01-01") + sample(0:(365*13), n_conditions, replace = TRUE),
    condition_end_datetime = as.POSIXct("2010-01-01") + sample(0:(365*13*24*3600), n_conditions, replace = TRUE),
    condition_type_concept_id = 32020,
    condition_status_concept_id = 0,
    stop_reason = "",
    provider_id = sample(1:50, n_conditions, replace = TRUE),
    visit_occurrence_id = sample(1:n_visits, n_conditions, replace = TRUE),
    visit_detail_id = as.integer(NA),
    condition_source_value = paste0("C", sprintf("%06d", 1:n_conditions)),
    condition_source_concept_id = 0,
    condition_status_source_value = "",
    stringsAsFactors = FALSE
  )
}

.create_drug_exposure_table <- function(n_drugs, n_patients, n_visits) {
  data.frame(
    drug_exposure_id = 1:n_drugs,
    person_id = sample(1:n_patients, n_drugs, replace = TRUE),
    drug_concept_id = sample(c(1125315, 1154343, 907013, 974166), n_drugs, replace = TRUE), # Common drugs
    drug_exposure_start_date = as.Date("2010-01-01") + sample(0:(365*13), n_drugs, replace = TRUE),
    drug_exposure_start_datetime = as.POSIXct("2010-01-01") + sample(0:(365*13*24*3600), n_drugs, replace = TRUE),
    drug_exposure_end_date = as.Date("2010-01-01") + sample(0:(365*13), n_drugs, replace = TRUE),
    drug_exposure_end_datetime = as.POSIXct("2010-01-01") + sample(0:(365*13*24*3600), n_drugs, replace = TRUE),
    verbatim_end_date = as.Date(NA),
    drug_type_concept_id = 38000177,
    stop_reason = "",
    refills = sample(0:5, n_drugs, replace = TRUE),
    quantity = sample(30:90, n_drugs, replace = TRUE),
    days_supply = sample(30:90, n_drugs, replace = TRUE),
    sig = "Take as directed",
    route_concept_id = 4132161,
    lot_number = "",
    provider_id = sample(1:50, n_drugs, replace = TRUE),
    visit_occurrence_id = sample(1:n_visits, n_drugs, replace = TRUE),
    visit_detail_id = as.integer(NA),
    drug_source_value = paste0("D", sprintf("%06d", 1:n_drugs)),
    drug_source_concept_id = 0,
    route_source_value = "Oral",
    dose_unit_source_value = "mg",
    stringsAsFactors = FALSE
  )
}