#' Setup OMOP CDM with Eunomia Datasets
#'
#' Creates an in-memory OMOP Common Data Model (CDM) database using Eunomia 
#' synthetic datasets. Eunomia provides several pre-built OMOP CDM datasets 
#' including Synthea-generated data and CMS SynPUF data.
#'
#' @param dataset_name Character string specifying the dataset to use. 
#'   Available options include:
#'   - "GiBleed" (default): Small dataset for testing
#'   - "synthea-allergies-10k": Synthea allergies data (10k patients)
#'   - "synthea-covid19-10k": Synthea COVID-19 data (10k patients)
#'   - "synthea-covid19-200k": Synthea COVID-19 data (200k patients)
#'   - "synthea-heart-10k": Synthea heart disease data
#'   - "synpuf-1k": CMS Synthetic Public Use Files (1k patients)
#'   See Details for complete list.
#' @param cdm_version Character string specifying OMOP CDM version. 
#'   Must be "5.3" or "5.4". Default is "5.3".
#' @param verbose Logical indicating whether to print progress messages. 
#'   Default is TRUE.
#'
#' @return A list containing:
#'   \item{cdm}{CDM reference object from CDMConnector}
#'   \item{connection}{DBI connection to the database}
#'
#' @details
#' Available Eunomia datasets include:
#' \itemize{
#'   \item GiBleed - Default small dataset for testing
#'   \item synthea-allergies-10k - Synthea allergies data
#'   \item synthea-anemia-10k - Synthea anemia data
#'   \item synthea-breast_cancer-10k - Synthea breast cancer data
#'   \item synthea-contraceptives-10k - Synthea contraceptives data
#'   \item synthea-covid19-10k - Synthea COVID-19 data (10k patients)
#'   \item synthea-covid19-200k - Synthea COVID-19 data (200k patients)
#'   \item synthea-dermatitis-10k - Synthea dermatitis data
#'   \item synthea-heart-10k - Synthea heart disease data
#'   \item synthea-hiv-10k - Synthea HIV data
#'   \item synthea-lung_cancer-10k - Synthea lung cancer data
#'   \item synthea-medications-10k - Synthea medications data
#'   \item synthea-metabolic_syndrome-10k - Synthea metabolic syndrome data
#'   \item synthea-opioid_addiction-10k - Synthea opioid addiction data
#'   \item synthea-rheumatoid_arthritis-10k - Synthea rheumatoid arthritis data
#'   \item synthea-snf-10k - Synthea skilled nursing facility data
#'   \item synthea-surgery-10k - Synthea surgery data
#'   \item synthea-total_joint_replacement-10k - Synthea joint replacement data
#'   \item synpuf-1k - CMS Synthetic Public Use Files
#' }
#'
#' The function automatically sets up the EUNOMIA_DATA_FOLDER environment 
#' variable if not already configured. Data will be downloaded on first use.
#'
#' @examples
#' \dontrun{
#' # Setup with default GiBleed dataset
#' cdm_setup <- setup_omop_cdm_eunomia()
#' 
#' # Explore the data
#' print(cdm_setup$cdm)
#' 
#' # Clean up
#' cdmDisconnect(cdm_setup$cdm)
#' 
#' # Setup with COVID-19 dataset
#' covid_setup <- setup_omop_cdm_eunomia("synthea-covid19-10k")
#' cdmDisconnect(covid_setup$cdm)
#' }
#'
#' @seealso \code{\link{explore_cdm}}, \code{\link{plot_cdm_demographics}}
#'
#' @export
#' @importFrom CDMConnector eunomiaDir cdmFromCon cdmDisconnect
#' @importFrom DBI dbConnect
#' @importFrom duckdb duckdb
setup_omop_cdm_eunomia <- function(dataset_name = "GiBleed", 
                                   cdm_version = "5.3", 
                                   verbose = TRUE) {
  
  # Validate inputs
  available_datasets <- c(
    "GiBleed", "synthea-allergies-10k", "synthea-anemia-10k", 
    "synthea-breast_cancer-10k", "synthea-contraceptives-10k",
    "synthea-covid19-10k", "synthea-covid19-200k", "synthea-dermatitis-10k",
    "synthea-heart-10k", "synthea-hiv-10k", "synthea-lung_cancer-10k",
    "synthea-medications-10k", "synthea-metabolic_syndrome-10k",
    "synthea-opioid_addiction-10k", "synthea-rheumatoid_arthritis-10k",
    "synthea-snf-10k", "synthea-surgery-10k", 
    "synthea-total_joint_replacement-10k", "synpuf-1k"
  )
  
  if (!dataset_name %in% available_datasets) {
    stop("Invalid dataset_name. Available options: ", 
         paste(available_datasets, collapse = ", "))
  }
  
  if (!cdm_version %in% c("5.3", "5.4")) {
    stop("cdm_version must be '5.3' or '5.4'")
  }
  
  if (verbose) {
    message("Setting up OMOP CDM with Eunomia dataset: ", dataset_name)
  }
  
  # Set up Eunomia data folder if not configured
  if (Sys.getenv("EUNOMIA_DATA_FOLDER") == "") {
    data_folder <- file.path(tempdir(), "eunomia_data")
    dir.create(data_folder, recursive = TRUE, showWarnings = FALSE)
    Sys.setenv(EUNOMIA_DATA_FOLDER = data_folder)
    if (verbose) {
      message("Set EUNOMIA_DATA_FOLDER to: ", data_folder)
    }
  }
  
  # Create connection to DuckDB with Eunomia data
  tryCatch({
    db_path <- CDMConnector::eunomiaDir(
      datasetName = dataset_name, 
      cdmVersion = cdm_version
    )
    con <- DBI::dbConnect(duckdb::duckdb(), db_path)
    
    # Create CDM reference object
    cdm <- CDMConnector::cdmFromCon(
      con = con,
      cdmName = paste0("eunomia_", dataset_name),
      cdmSchema = "main",
      writeSchema = "main"
    )
    
    if (verbose) {
      message("CDM created successfully!")
      print(cdm)
    }
    
    return(list(cdm = cdm, connection = con))
    
  }, error = function(e) {
    stop("Failed to setup CDM: ", e$message)
  })
}

#' Setup OMOP CDM using Eunomia Package Directly
#'
#' Creates a connection to an OMOP CDM database using the Eunomia package 
#' directly rather than through CDMConnector. This provides a simpler 
#' interface for basic database operations.
#'
#' @param verbose Logical indicating whether to print progress messages. 
#'   Default is TRUE.
#'
#' @return A list containing:
#'   \item{connection}{DatabaseConnector connection object}
#'   \item{connectionDetails}{Connection details for the database}
#'
#' @examples
#' \dontrun{
#' # Setup direct Eunomia connection
#' eunomia_conn <- setup_omop_cdm_eunomia_direct()
#' 
#' # Query the database
#' person_count <- querySql(eunomia_conn$connection, 
#'                         "SELECT COUNT(*) as count FROM person")
#' print(person_count)
#' 
#' # Clean up
#' disconnect(eunomia_conn$connection)
#' }
#'
#' @export
#' @importFrom DatabaseConnector connect disconnect querySql
setup_omop_cdm_eunomia_direct <- function(verbose = TRUE) {
  
  if (verbose) {
    message("Setting up OMOP CDM using Eunomia package directly")
  }
  
  # Check if Eunomia is available
  if (!requireNamespace("Eunomia", quietly = TRUE)) {
    stop("Eunomia package is required but not installed. ",
         "Install it with: install.packages('Eunomia')")
  }
  
  # Get connection details for default dataset
  tryCatch({
    connectionDetails <- Eunomia::getEunomiaConnectionDetails()
    connection <- DatabaseConnector::connect(connectionDetails)
    
    if (verbose) {
      # Get table names
      tables <- DatabaseConnector::getTableNames(connection, 
                                                 databaseSchema = 'main')
      message("Connection established. Available tables: ")
      message(paste(tables, collapse = ", "))
      
      # Test query
      person_count <- DatabaseConnector::querySql(
        connection, 
        "SELECT COUNT(*) as person_count FROM person;"
      )
      message("Total persons in database: ", person_count$PERSON_COUNT)
    }
    
    return(list(connection = connection, 
                connectionDetails = connectionDetails))
    
  }, error = function(e) {
    stop("Failed to setup Eunomia connection: ", e$message)
  })
}