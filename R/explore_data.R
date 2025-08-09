#' Explore OMOP CDM Data
#'
#' Provides basic statistics and exploration of an OMOP CDM database.
#' This function generates summary statistics for key tables including
#' patient counts, visit counts, condition counts, and demographic distributions.
#'
#' @param cdm A CDM reference object created by \code{\link{setup_omop_cdm_eunomia}}
#'   or a similar CDMConnector CDM object.
#' @param verbose Logical indicating whether to print detailed output.
#'   Default is TRUE.
#'
#' @return A list containing summary statistics:
#'   \item{total_persons}{Total number of persons in the database}
#'   \item{total_visits}{Total number of visits}
#'   \item{total_conditions}{Total number of condition occurrences}
#'   \item{total_drugs}{Total number of drug exposures}
#'   \item{gender_distribution}{Data frame with gender distribution}
#'   \item{age_statistics}{Data frame with age statistics}
#'
#' @details
#' The function calculates the following statistics:
#' \itemize{
#'   \item Basic counts for persons, visits, conditions, and drug exposures
#'   \item Gender distribution by concept ID
#'   \item Age distribution including min, max, mean, and median ages
#' }
#'
#' Ages are calculated assuming the current year is 2024.
#'
#' @examples
#' \dontrun{
#' # Setup CDM and explore
#' cdm_setup <- setup_omop_cdm_eunomia()
#' stats <- explore_cdm(cdm_setup$cdm)
#' 
#' # Access specific statistics
#' print(stats$total_persons)
#' print(stats$gender_distribution)
#' 
#' # Clean up
#' cdmDisconnect(cdm_setup$cdm)
#' }
#'
#' @seealso \code{\link{plot_cdm_demographics}}, \code{\link{setup_omop_cdm_eunomia}}
#'
#' @export
#' @importFrom dplyr %>% tally pull group_by summarise collect mutate
explore_cdm <- function(cdm, verbose = TRUE) {
  
  if (verbose) {
    message("CDM Exploration")
    cat("=== CDM Exploration ===\n")
  }
  
  # Validate CDM object
  if (!("cdm_reference" %in% class(cdm))) {
    stop("cdm must be a CDM reference object created by CDMConnector")
  }
  
  # Basic statistics
  if (verbose) cat("\nBasic Statistics:\n")
  
  total_persons <- cdm$person %>% dplyr::tally() %>% dplyr::pull(n)
  total_visits <- cdm$visit_occurrence %>% dplyr::tally() %>% dplyr::pull(n)
  total_conditions <- cdm$condition_occurrence %>% dplyr::tally() %>% dplyr::pull(n)
  total_drugs <- cdm$drug_exposure %>% dplyr::tally() %>% dplyr::pull(n)
  
  if (verbose) {
    cat("Total persons:", total_persons, "\n")
    cat("Total visits:", total_visits, "\n")
    cat("Total conditions:", total_conditions, "\n")
    cat("Total drug exposures:", total_drugs, "\n")
  }
  
  # Gender distribution
  if (verbose) cat("\nGender Distribution:\n")
  gender_dist <- cdm$person %>%
    dplyr::group_by(gender_concept_id) %>%
    dplyr::summarise(count = n(), .groups = "drop") %>%
    dplyr::collect()
  
  if (verbose) print(gender_dist)
  
  # Age distribution
  if (verbose) cat("\nAge Distribution (current year 2024):\n")
  age_dist <- cdm$person %>%
    dplyr::mutate(age = 2024 - year_of_birth) %>%
    dplyr::summarise(
      min_age = min(age, na.rm = TRUE),
      max_age = max(age, na.rm = TRUE),
      mean_age = mean(age, na.rm = TRUE),
      median_age = median(age, na.rm = TRUE)
    ) %>%
    dplyr::collect()
  
  if (verbose) print(age_dist)
  
  # Return summary statistics
  list(
    total_persons = total_persons,
    total_visits = total_visits,
    total_conditions = total_conditions,
    total_drugs = total_drugs,
    gender_distribution = gender_dist,
    age_statistics = age_dist
  )
}

#' Plot CDM Demographics
#'
#' Creates demographic visualizations for an OMOP CDM database including
#' age and gender distributions.
#'
#' @param cdm A CDM reference object created by \code{\link{setup_omop_cdm_eunomia}}
#'   or a similar CDMConnector CDM object.
#' @param bins Integer specifying the number of bins for the age histogram.
#'   Default is 30.
#' @param alpha Numeric value between 0 and 1 specifying the transparency
#'   of the histogram bars. Default is 0.7.
#'
#' @return A ggplot2 object showing the age distribution by gender.
#'
#' @details
#' The function creates a histogram showing the age distribution of patients
#' in the CDM, colored by gender. Ages are calculated assuming the current
#' year is 2024. Gender concept IDs are mapped to readable labels:
#' \itemize{
#'   \item 8532 = Female
#'   \item 8507 = Male
#'   \item Other values = Other
#' }
#'
#' @examples
#' \dontrun{
#' # Setup CDM and create plot
#' cdm_setup <- setup_omop_cdm_eunomia()
#' plot <- plot_cdm_demographics(cdm_setup$cdm)
#' print(plot)
#' 
#' # Customize the plot
#' plot_custom <- plot_cdm_demographics(cdm_setup$cdm, bins = 20, alpha = 0.5)
#' print(plot_custom)
#' 
#' # Clean up
#' cdmDisconnect(cdm_setup$cdm)
#' }
#'
#' @seealso \code{\link{explore_cdm}}, \code{\link{setup_omop_cdm_eunomia}}
#'
#' @export
#' @importFrom dplyr %>% mutate select collect case_when
#' @importFrom ggplot2 ggplot aes geom_histogram labs theme_minimal
plot_cdm_demographics <- function(cdm, bins = 30, alpha = 0.7) {
  
  # Validate CDM object
  if (!("cdm_reference" %in% class(cdm))) {
    stop("cdm must be a CDM reference object created by CDMConnector")
  }
  
  # Validate parameters
  if (!is.numeric(bins) || bins <= 0) {
    stop("bins must be a positive number")
  }
  
  if (!is.numeric(alpha) || alpha < 0 || alpha > 1) {
    stop("alpha must be a number between 0 and 1")
  }
  
  # Extract demographic data
  demo_data <- cdm$person %>%
    dplyr::mutate(
      age = 2024 - year_of_birth,
      gender = dplyr::case_when(
        gender_concept_id == 8532 ~ "Female",
        gender_concept_id == 8507 ~ "Male",
        TRUE ~ "Other"
      )
    ) %>%
    dplyr::select(age, gender) %>%
    dplyr::collect()
  
  # Create plot
  p1 <- ggplot2::ggplot(demo_data, ggplot2::aes(x = age, fill = gender)) +
    ggplot2::geom_histogram(bins = bins, alpha = alpha, position = "identity") +
    ggplot2::labs(
      title = "Age Distribution by Gender",
      x = "Age", 
      y = "Count", 
      fill = "Gender"
    ) +
    ggplot2::theme_minimal()
  
  return(p1)
}

#' Run Complete OMOP CDM Demo
#'
#' Executes a comprehensive demonstration of the OMOPSynth package capabilities
#' including setting up CDM databases, exploring data, and creating visualizations.
#'
#' @param dataset_name Character string specifying the Eunomia dataset to use.
#'   Default is "GiBleed".
#' @param n_synthetic_patients Integer specifying the number of synthetic patients
#'   to generate for the custom synthetic data demo. Default is 500.
#' @param create_plots Logical indicating whether to create and display plots.
#'   Default is TRUE.
#' @param verbose Logical indicating whether to print detailed progress messages.
#'   Default is TRUE.
#'
#' @return Invisibly returns a list containing:
#'   \item{eunomia_stats}{Statistics from the Eunomia dataset}
#'   \item{synthetic_stats}{Statistics from the synthetic dataset}
#'   \item{plots}{List of generated plots (if create_plots = TRUE)}
#'
#' @details
#' This function demonstrates the main features of the OMOPSynth package:
#' \enumerate{
#'   \item Sets up an OMOP CDM using Eunomia datasets
#'   \item Explores the data and generates statistics
#'   \item Creates demographic visualizations
#'   \item Sets up a custom synthetic OMOP CDM
#'   \item Compares the two approaches
#' }
#'
#' All database connections are properly closed at the end of the demo.
#'
#' @examples
#' \dontrun{
#' # Run complete demo with default settings
#' demo_results <- demo_omop_cdm_setup()
#' 
#' # Run demo with custom parameters
#' demo_results <- demo_omop_cdm_setup(
#'   dataset_name = "synthea-covid19-10k",
#'   n_synthetic_patients = 1000,
#'   create_plots = TRUE
#' )
#' 
#' # Access results
#' print(demo_results$eunomia_stats)
#' print(demo_results$synthetic_stats)
#' }
#'
#' @seealso \code{\link{setup_omop_cdm_eunomia}}, \code{\link{create_synthetic_omop_data}}, \code{\link{explore_cdm}}
#'
#' @export
#' @importFrom CDMConnector cdmDisconnect
#' @importFrom DBI dbGetQuery dbDisconnect
demo_omop_cdm_setup <- function(dataset_name = "GiBleed",
                                n_synthetic_patients = 500,
                                create_plots = TRUE,
                                verbose = TRUE) {
  
  if (verbose) {
    cat("=== OMOP CDM In-Memory Database Demo ===\n\n")
  }
  
  # Initialize results list
  results <- list()
  plots <- list()
  
  # Method 1: CDMConnector with Eunomia
  if (verbose) {
    cat("1. Setting up CDM with Eunomia", dataset_name, "dataset...\n")
  }
  
  tryCatch({
    eunomia_setup <- setup_omop_cdm_eunomia(dataset_name, verbose = verbose)
    
    # Explore the data
    eunomia_stats <- explore_cdm(eunomia_setup$cdm, verbose = verbose)
    results$eunomia_stats <- eunomia_stats
    
    # Create demographic plot
    if (create_plots) {
      eunomia_plot <- plot_cdm_demographics(eunomia_setup$cdm)
      plots$eunomia_demographics <- eunomia_plot
      print(eunomia_plot)
    }
    
    # Cleanup Eunomia
    CDMConnector::cdmDisconnect(eunomia_setup$cdm)
    
  }, error = function(e) {
    if (verbose) {
      cat("Error with Eunomia setup:", e$message, "\n")
    }
  })
  
  # Method 2: Custom synthetic data
  if (verbose) {
    cat("\n2. Creating custom synthetic OMOP CDM data...\n")
  }
  
  tryCatch({
    synthetic_con <- create_synthetic_omop_data(
      n_patients = n_synthetic_patients,
      verbose = verbose
    )
    
    # Query synthetic data
    if (verbose) cat("\nSynthetic data summary:\n")
    person_count <- DBI::dbGetQuery(synthetic_con, 
                                    "SELECT COUNT(*) as count FROM person")
    visit_count <- DBI::dbGetQuery(synthetic_con, 
                                   "SELECT COUNT(*) as count FROM visit_occurrence")
    condition_count <- DBI::dbGetQuery(synthetic_con, 
                                       "SELECT COUNT(*) as count FROM condition_occurrence")
    drug_count <- DBI::dbGetQuery(synthetic_con, 
                                  "SELECT COUNT(*) as count FROM drug_exposure")
    
    synthetic_stats <- list(
      total_persons = person_count$count,
      total_visits = visit_count$count,
      total_conditions = condition_count$count,
      total_drugs = drug_count$count
    )
    
    results$synthetic_stats <- synthetic_stats
    
    if (verbose) {
      cat("Persons:", synthetic_stats$total_persons, "\n")
      cat("Visits:", synthetic_stats$total_visits, "\n")
      cat("Conditions:", synthetic_stats$total_conditions, "\n")
      cat("Drug exposures:", synthetic_stats$total_drugs, "\n")
    }
    
    # Cleanup synthetic
    DBI::dbDisconnect(synthetic_con)
    
  }, error = function(e) {
    if (verbose) {
      cat("Error with synthetic data setup:", e$message, "\n")
    }
  })
  
  if (create_plots) {
    results$plots <- plots
  }
  
  if (verbose) {
    cat("\nDemo completed successfully!\n")
  }
  
  invisible(results)
}