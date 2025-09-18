# README.md

# OMOPSynth <img src="man/figures/logo.png" align="right" height="139"/>

<!-- badges: start -->

[![R-CMD-check](https://github.com/tjohnson250/OMOPSynth/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/yourusername/OMOPSynth/actions/workflows/R-CMD-check.yaml) [![CRAN status](https://www.r-pkg.org/badges/version/OMOPSynth)](https://CRAN.R-project.org/package=OMOPSynth) [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

## Overview

OMOPSynth provides tools for setting up in-memory OMOP Common Data Model (CDM) databases with synthetic data for testing, development, and demonstration purposes. The package supports multiple approaches including Eunomia datasets from the OHDSI community and custom synthetic data generation.

## Features

-   🚀 **Quick Setup**: Get an OMOP CDM running in seconds
-   📊 **Multiple Data Sources**: Eunomia datasets and custom synthetic data
-   🔍 **Data Exploration**: Built-in functions for exploring CDM data
-   📈 **Visualization**: Demographic and statistical plots
-   🧪 **Testing Ready**: Perfect for unit tests and development
-   📚 **Well Documented**: Comprehensive help and examples

## Installation

You can install the development version of OMOPSynth from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tjohnson250/OMOPSynth")
```

## Quick Start

``` r
library(OMOPSynth)

# Run the complete demo
demo_omop_cdm_setup()

# Or setup step by step
cdm_setup <- setup_omop_cdm_eunomia("GiBleed")
explore_cdm(cdm_setup$cdm)
plot_cdm_demographics(cdm_setup$cdm)

# Clean up
cdmDisconnect(cdm_setup$cdm)
```

## Available Datasets

The package provides access to numerous synthetic datasets:

``` r
# See all available datasets
datasets <- get_available_datasets()
print(datasets)

# Setup with different datasets
covid_setup <- setup_omop_cdm_eunomia("synthea-covid19-10k")
heart_setup <- setup_omop_cdm_eunomia("synthea-heart-10k")
```

## Custom Synthetic Data

Generate your own synthetic OMOP CDM data:

``` r
# Create synthetic data for 1000 patients
synthetic_db <- create_synthetic_omop_data(n_patients = 1000)

# Query the data
DBI::dbGetQuery(synthetic_db, "SELECT COUNT(*) FROM person")

# Clean up
DBI::dbDisconnect(synthetic_db)
```

## Use Cases

-   **Package Development**: Test OMOP CDM packages without real data
-   **Education**: Learn OMOP CDM structure and analysis
-   **Prototyping**: Rapidly prototype healthcare analytics
-   **Unit Testing**: Create reproducible test datasets
-   **Demonstrations**: Show OMOP CDM capabilities

## Documentation

-   Get started: `vignette("getting-started", package = "OMOPSynth")`
-   Advanced usage: `vignette("advanced-usage", package = "OMOPSynth")`
-   Function reference: [Package website](https://yourusername.github.io/OMOPSynth/)

## Requirements

-   R ≥ 4.0.0
-   Java ≥ 8 (for some OHDSI packages)

## Related Packages

-   [CDMConnector](https://darwin-eu.github.io/CDMConnector/): Core OMOP CDM interface
-   [Eunomia](https://github.com/OHDSI/Eunomia): OHDSI synthetic datasets
-   [DatabaseConnector](https://github.com/OHDSI/DatabaseConnector): OHDSI database utilities
-   [OHDSI Tools](https://ohdsi.org/software-tools/): Complete OHDSI ecosystem

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## Code of Conduct

Please note that the OMOPSynth project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## License

MIT © [Your Name](LICENSE.md)
