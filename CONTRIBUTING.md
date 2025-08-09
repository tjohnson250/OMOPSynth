# CONTRIBUTING.md
# Contributing to OMOPSynth

We love your input! We want to make contributing to OMOPSynth as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Pull Request Process

1. Update the README.md with details of changes to the interface, if applicable.
2. Update the NEWS.md file with a note describing your changes.
3. Increase the version number in DESCRIPTION to the new version that this Pull Request would represent.
4. Your Pull Request will be merged once you have the sign-off of at least one maintainer.

## Code Style

We follow the [tidyverse style guide](https://style.tidyverse.org/). Please run `styler::style_pkg()` before submitting your PR.

## Testing

- Write tests for any new functionality
- Ensure all tests pass with `devtools::test()`
- Aim for >80% test coverage

## Documentation

- Document all exported functions with roxygen2
- Include examples in function documentation
- Update vignettes if adding major functionality

## Report bugs using GitHub Issues

We use GitHub issues to track public bugs. Report a bug by opening a new issue.

**Bug reports should include:**
- A quick summary and/or background
- Steps to reproduce
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
