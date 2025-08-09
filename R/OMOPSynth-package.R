# R/OMOPSynth-package.R
#' OMOPSynth: Synthetic OMOP Common Data Model Database Setup
#'
#' @description
#' The OMOPSynth package provides tools for setting up in-memory OMOP Common 
#' Data Model (CDM) databases with synthetic data for testing, development, 
#' and demonstration purposes. It supports multiple approaches including 
#' Eunomia datasets from the OHDSI community and custom synthetic data generation.
#'
#' @details
#' The package offers several key functions:
#' 
#' **Data Setup Functions:**
#' \itemize{
#'   \item \code{\link{setup_omop_cdm_eunomia}}: Setup CDM with Eunomia datasets
#'   \item \code{\link{create_synthetic_omop_data}}: Create custom synthetic data
#'   \item \code{\link{setup_omop_cdm_eunomia_direct}}: Direct Eunomia access
#' }
#' 
#' **Data Exploration Functions:**
#' \itemize{
#'   \item \code{\link{explore_cdm}}: Generate summary statistics
#'   \item \code{\link{plot_cdm_demographics}}: Create demographic visualizations
#' }
#' 
#' **Demo and Utility Functions:**
#' \itemize{
#'   \item \code{\link{demo_omop_cdm_setup}}: Complete package demonstration
#'   \item \code{\link{check_and_install_packages}}: Install required packages
#'   \item \code{\link{get_available_datasets}}: List available datasets
#' }
#'
#' @section Getting Started:
#' 
#' The easiest way to get started is with the demo function:
#' 
#' \code{demo_omop_cdm_setup()}
#' 
#' For basic usage with Eunomia data:
#' 
#' \preformatted{
#' # Setup CDM with default dataset
#' cdm_setup <- setup_omop_cdm_eunomia()
#' 
#' # Explore the data  
#' explore_cdm(cdm_setup$cdm)
#' 
#' # Create demographic plots
#' plot_cdm_demographics(cdm_setup$cdm)
#' 
#' # Clean up
#' cdmDisconnect(cdm_setup$cdm)
#' }
#'
#' @section Available Datasets:
#' 
#' The package provides access to numerous Eunomia datasets including:
#' \itemize{
#'   \item GiBleed: Small test dataset
#'   \item Multiple Synthea condition-specific datasets (COVID-19, heart disease, cancer, etc.)
#'   \item CMS SynPUF synthetic Medicare data
#' }
#' 
#' Use \code{get_available_datasets()} to see all options.
#'
#' @section Dependencies:
#' 
#' This package depends on several OHDSI and database packages:
#' \itemize{
#'   \item CDMConnector: Core OMOP CDM interface
#'   \item DuckDB: High-performance analytical database
#'   \item DatabaseConnector: OHDSI database connection utilities
#'   \item dplyr: Data manipulation
#'   \item ggplot2: Data visualization
#' }
#'
#' @author Your Name \email{your.email@example.com}
#' 
#' @references
#' \itemize{
#'   \item OHDSI Collaborative. The Book of OHDSI. Available at: \url{https://ohdsi.github.io/TheBookOfOhdsi/}
#'   \item OMOP Common Data Model: \url{https://ohdsi.github.io/CommonDataModel/}
#'   \item CDMConnector: \url{https://darwin-eu.github.io/CDMConnector/}
#'   \item Eunomia: \url{https://github.com/OHDSI/Eunomia}
#' }
#'
#' @keywords package
"_PACKAGE"

# Global variables to avoid R CMD check notes
utils::globalVariables(c(
  "n", "age", "gender_concept_id", "year_of_birth", "count",
  "person_id", "visit_occurrence_id", "condition_concept_id",
  "drug_concept_id", "."
))