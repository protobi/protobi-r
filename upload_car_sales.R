#!/usr/bin/env Rscript

# Simple test script to upload data to Protobi
# Install required packages if needed:
#   install.packages(c("httr", "jsonlite"))

if (!require("httr", quietly = TRUE)) stop("httr package required")
if (!require("jsonlite", quietly = TRUE)) stop("jsonlite package required")

# Credentials
host <- "https://app.protobi.com"
dataset_id <- "687e55b79d1c392e37009512"
table_key <- "data_fall2026_20260309"
api_key <- Sys.getenv("PROTOBI_TEST_API_KEY")

# Create simple test data
df <- data.frame(
  id = 1:10,
  name = paste0("Test", 1:10),
  value = rnorm(10),
  category = sample(c("A", "B", "C"), 10, replace = TRUE),
  stringsAsFactors = FALSE
)

cat("Created test data:", nrow(df), "rows x", ncol(df), "columns\n")
cat("Uploading to:", host, "\n")
cat("Dataset ID:", dataset_id, "\n")
cat("Table Key:", table_key, "\n\n")

# Write to temporary CSV
temp_path <- tempfile()
write.csv(df, temp_path, na="", row.names=TRUE)

# Upload
uri <- paste0(host, "/api/v3/dataset/", dataset_id, "/data/", table_key)
cat("POST to:", uri, "\n\n")

response <- httr::POST(
  uri,
  body = list(
    file = httr::upload_file(temp_path, "text/csv"),
    type = "data",
    filename = "data.csv"
  ),
  httr::add_headers(`x-api-key` = api_key),
  httr::config(ssl_verifypeer = 0L, ssl_verifyhost = 0L)
)

unlink(temp_path)

content <- httr::content(response, as="text", encoding="UTF-8")
result <- jsonlite::fromJSON(content)

cat("\n=== Result ===\n")
print(result)

if (!is.null(result$complete) && result$complete) {
  cat("\nSUCCESS!\n")
} else if (!is.null(result$error)) {
  cat("\nERROR:", result$error, "\n")
} else {
  cat("\nStatus:", httr::status_code(response), "\n")
}
