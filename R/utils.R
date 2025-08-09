# R/utils.R
#' Check and Install Required Packages
#'
#' Utility function to check for and install required packages for OMOPSynth.
#' This function is particularly useful for first-time setup.
#'
#' @param packages Character vector of package names to check and install.
#'   If NULL (default), checks all required packages for OMOPSynth.
#' @param quietly Logical indicating whether to suppress installation messages.
#'   Default is FALSE.
#'
#' @return Logical vector indicating which packages were successfully loaded.
#'
#' @examples
#' \dontrun{
#' # Check and install all required packages
#' check_and_install_packages()
#' 
#' # Check specific packages
#' check_and_install_packages(c("dplyr", "ggplot2"))
#' }
#'
#' @export
#' @importFrom utils install.packages installed.packages
check_and_install_packages <- function(packages = NULL, quietly = FALSE) {
  
  if (is.null(packages)) {
    packages <- c("CDMConnector", "duckdb", "DBI", "dplyr", "ggplot2", 
                  "DatabaseConnector", "SqlRender", "RSQLite")
  }
  
  success <- logical(length(packages))
  names(success) <- packages
  
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      if (!quietly) {
        message("Installing package: ", pkg)
      }
      
      tryCatch({
        utils::install.packages(pkg)
        success[pkg] <- requireNamespace(pkg, quietly = TRUE)
      }, error = function(e) {
        warning("Failed to install package: ", pkg, " - ", e$message)
        success[pkg] <- FALSE
      })
    } else {
      success[pkg] <- TRUE
    }
  }
  
  if (!quietly) {
    installed <- sum(success)
    total <- length(packages)
    message("Successfully loaded ", installed, " out of ", total, " packages")
  }
  
  return(success)
}

#' Get Available Eunomia Datasets
#'
#' Returns a list of available Eunomia datasets with descriptions.
#'
#' @return A data frame with dataset names and descriptions.
#'
#' @examples
#' datasets <- get_available_datasets()
#' print(datasets)
#'
#' @export
get_available_datasets <- function() {
  data.frame(
    dataset_name = c(
      "GiBleed",
      "synthea-allergies-10k",
      "synthea-anemia-10k",
      "synthea-breast_cancer-10k",
      "synthea-contraceptives-10k",
      "synthea-covid19-10k",
      "synthea-covid19-200k",
      "synthea-dermatitis-10k",
      "synthea-heart-10k",
      "synthea-hiv-10k",
      "synthea-lung_cancer-10k",
      "synthea-medications-10k",
      "synthea-metabolic_syndrome-10k",
      "synthea-opioid_addiction-10k",
      "synthea-rheumatoid_arthritis-10k",
      "synthea-snf-10k",
      "synthea-surgery-10k",
      "synthea-total_joint_replacement-10k",
      "synpuf-1k"
    ),
    description = c(
      "Default small dataset for testing",
      "Synthea allergies data (10k patients)",
      "Synthea anemia data (10k patients)",
      "Synthea breast cancer data (10k patients)",
      "Synthea contraceptives data (10k patients)",
      "Synthea COVID-19 data (10k patients)",
      "Synthea COVID-19 data (200k patients)",
      "Synthea dermatitis data (10k patients)",
      "Synthea heart disease data (10k patients)",
      "Synthea HIV data (10k patients)",
      "Synthea lung cancer data (10k patients)",
      "Synthea medications data (10k patients)",
      "Synthea metabolic syndrome data (10k patients)",
      "Synthea opioid addiction data (10k patients)",
      "Synthea rheumatoid arthritis data (10k patients)",
      "Synthea skilled nursing facility data (10k patients)",
      "Synthea surgery data (10k patients)",
      "Synthea joint replacement data (10k patients)",
      "CMS Synthetic Public Use Files (1k patients)"
    ),
    stringsAsFactors = FALSE
  )
}

#' Validate CDM Object
#'
#' Internal utility function to validate CDM reference objects.
#'
#' @param cdm CDM reference object to validate
#' @param required_tables Character vector of required table names
#'
#' @return TRUE if valid, stops with error if not
#'
#' @keywords internal
.validate_cdm <- function(cdm, required_tables = c("person")) {
  if (!methods::is(cdm, "cdm_reference")) {
    stop("cdm must be a CDM reference object created by CDMConnector")
  }
  
  available_tables <- names(cdm)
  missing_tables <- setdiff(required_tables, available_tables)
  
  if (length(missing_tables) > 0) {
    stop("Required tables missing from CDM: ", paste(missing_tables, collapse = ", "))
  }
  
  return(TRUE)
}
