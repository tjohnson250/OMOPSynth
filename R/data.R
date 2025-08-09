# R/data.R
#' Sample OMOP Concept Data
#'
#' A sample dataset containing common OMOP concept IDs and their descriptions
#' for demonstration purposes. This is a subset of the full OMOP vocabulary.
#'
#' @format A data frame with concept information:
#' \describe{
#'   \item{concept_id}{Unique identifier for the concept}
#'   \item{concept_name}{Human readable name of the concept}
#'   \item{domain_id}{Domain that the concept belongs to}
#'   \item{vocabulary_id}{Vocabulary that the concept is taken from}
#'   \item{concept_class_id}{Concept class of the concept}
#'   \item{concept_code}{Concept code as it appears in the source vocabulary}
#' }
#' @source Subset of OMOP Standardized Vocabularies
"sample_concepts"