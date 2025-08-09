# data-raw/sample_concepts.R
# Script to create sample_concepts dataset

library(dplyr)

# Create sample concept data for common conditions, drugs, and demographics
sample_concepts <- tribble(
  ~concept_id, ~concept_name, ~domain_id, ~vocabulary_id, ~concept_class_id, ~concept_code,
  # Gender concepts
  8507, "Male", "Gender", "Gender", "Gender", "M",
  8532, "Female", "Gender", "Gender", "Gender", "F",
  
  # Race concepts
  8515, "Asian", "Race", "Race", "Race", "Asian",
  8516, "Black or African American", "Race", "Race", "Race", "Black",
  8527, "White", "Race", "Race", "Race", "White", 
  8557, "Native Hawaiian or Other Pacific Islander", "Race", "Race", "Race", "Pacific Islander",
  
  # Ethnicity concepts
  38003563, "Hispanic or Latino", "Ethnicity", "Ethnicity", "Ethnicity", "Hispanic",
  38003564, "Not Hispanic or Latino", "Ethnicity", "Ethnicity", "Ethnicity", "Not Hispanic",
  
  # Common conditions
  201820, "Diabetes mellitus", "Condition", "SNOMED", "Clinical Finding", "73211009",
  141932, "Hypertensive disorder", "Condition", "SNOMED", "Clinical Finding", "38341003",
  372906, "Hyperlipidemia", "Condition", "SNOMED", "Clinical Finding", "55822004",
  4329847, "Myocardial infarction", "Condition", "SNOMED", "Clinical Finding", "22298006",
  313217, "Atrial fibrillation", "Condition", "SNOMED", "Clinical Finding", "49436004",
  314866, "Heart failure", "Condition", "SNOMED", "Clinical Finding", "84114007",
  
  # Common drugs
  1125315, "Metformin", "Drug", "RxNorm", "Ingredient", "6809",
  1154343, "Atorvastatin", "Drug", "RxNorm", "Ingredient", "83367",
  907013, "Lisinopril", "Drug", "RxNorm", "Ingredient", "29046",
  974166, "Amlodipine", "Drug", "RxNorm", "Ingredient", "17767",
  
  # Visit types
  9201, "Inpatient Visit", "Visit", "Visit", "Visit", "IP",
  9202, "Outpatient Visit", "Visit", "Visit", "Visit", "OP", 
  9203, "Emergency Room Visit", "Visit", "Visit", "Visit", "ER",
  262, "Emergency Room and Inpatient Visit", "Visit", "Visit", "Visit", "EI",
  
  # Common measurements
  3025315, "Hemoglobin", "Measurement", "LOINC", "Lab Test", "718-7",
  3012888, "Body weight", "Measurement", "LOINC", "Clinical Observation", "29463-7",
  3004249, "Blood pressure", "Measurement", "LOINC", "Clinical Observation", "85354-9"
)

# Save the dataset
usethis::use_data(sample_concepts, overwrite = TRUE)
