# R/zzz.R
# Package startup and cleanup functions

.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "OMOPSynth ", utils::packageVersion("OMOPSynth"), " loaded successfully!\n",
    "Get started with: demo_omop_cdm_setup()\n",
    "For help: ?OMOPSynth or browseVignettes('OMOPSynth')"
  )
  
  # Check if EUNOMIA_DATA_FOLDER is set
  if (Sys.getenv("EUNOMIA_DATA_FOLDER") == "") {
    packageStartupMessage(
      "Note: Consider setting EUNOMIA_DATA_FOLDER environment variable\n",
      "Run: usethis::edit_r_environ() and add EUNOMIA_DATA_FOLDER='~/eunomia_data'"
    )
  }
}

.onLoad <- function(libname, pkgname) {
  # Set default options
  op <- options()
  op.omopsynth <- list(
    omopsynth.verbose = TRUE,
    omopsynth.default_dataset = "GiBleed",
    omopsynth.default_cdm_version = "5.3"
  )
  toset <- !(names(op.omopsynth) %in% names(op))
  if(any(toset)) options(op.omopsynth[toset])
  
  invisible()
}