#!/usr/bin/env Rscript

# Simple test runner script for command-line execution
# Usage: Rscript test.R
#    or: ./test.R (if executable)

# Load required packages
if (!require("testthat", quietly = TRUE)) {
  stop("testthat package not installed. Install with: install.packages('testthat')")
}

# Load dependencies that we need
if (!require("httr", quietly = TRUE)) {
  stop("httr package not installed. Run: make deps")
}
if (!require("jsonlite", quietly = TRUE)) {
  stop("jsonlite package not installed. Run: make deps")
}
if (!require("Hmisc", quietly = TRUE)) {
  warning("Hmisc package not installed. Some tests will be skipped. Run: make deps")
}

# Print header
cat("\n")
cat("========================================\n")
cat("  Running Protobi R Package Tests\n")
cat("========================================\n\n")

# Source the R files directly (avoids needing devtools or full package load)
cat("Loading package code...\n")
source("R/protobi.R")

cat("Running tests...\n\n")

# Run the tests
testthat::test_dir("tests/testthat", reporter = "progress")

cat("\n")
cat("========================================\n")
cat("  Tests Complete\n")
cat("========================================\n\n")
