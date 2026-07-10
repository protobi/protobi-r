#!/usr/bin/env Rscript

# Test script to reproduce client's 403 error when uploading data
# This script loads car_sales.sav and attempts to upload to the client's project

# Load required packages
if (!require("haven", quietly = TRUE)) {
  stop("haven package not installed. Install with: install.packages('haven')")
}
if (!require("httr", quietly = TRUE)) {
  stop("httr package not installed. Install with: install.packages('httr')")
}
if (!require("jsonlite", quietly = TRUE)) {
  stop("jsonlite package not installed. Install with: install.packages('jsonlite')")
}

# Source the protobi functions
source("R/protobi.R")

# Client credentials from the 403 error
host <- "https://app.protobi.com"
dataset_id <- "687e55b79d1c392e37009512"
table_key <- "car_sales"
api_key <- Sys.getenv("PROTOBI_TEST_API_KEY")

# Load the SAV file
sav_path <- "~/Exp/protobi-demo/public/data/sav/car_sales.sav"
sav_path <- path.expand(sav_path)

cat("Loading SAV file from:", sav_path, "\n")
df <- haven::read_sav(sav_path)

cat("Data loaded. Dimensions:", nrow(df), "rows x", ncol(df), "columns\n")
cat("Column names:", paste(names(df), collapse=", "), "\n\n")

# Convert to plain data frame (remove haven metadata)
df <- as.data.frame(df)

cat("Attempting to upload to Protobi...\n")
cat("Host:", host, "\n")
cat("Dataset ID:", dataset_id, "\n")
cat("Table Key:", table_key, "\n\n")

# Attempt the upload
result <- tryCatch({
  protobi_put_data(
    df = df,
    projectid = dataset_id,
    tablekey = table_key,
    apikey = api_key,
    host = host,
    timeout_seconds = 300
  )
}, error = function(e) {
  cat("\n!!! ERROR OCCURRED !!!\n")
  cat("Error message:", conditionMessage(e), "\n")

  # Try to get more details from the HTTP response if available
  if (exists("response", envir = parent.frame())) {
    cat("HTTP Status:", httr::status_code(response), "\n")
    cat("Response content:", httr::content(response, "text"), "\n")
  }

  return(list(error = TRUE, message = conditionMessage(e)))
})

cat("\n========================================\n")
cat("Result:\n")
print(result)
cat("========================================\n")
