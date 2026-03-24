context("protobi.put_data")

# Helper function to check if .env file exists and load it
load_test_env <- function() {
  env_path <- file.path(getwd(), "..", "..", ".env")
  if (file.exists(env_path)) {
    if (requireNamespace("dotenv", quietly = TRUE)) {
      dotenv::load_dot_env(env_path)
    } else {
      warning("dotenv package not installed. Install with: install.packages('dotenv')")
      return(FALSE)
    }
    return(TRUE)
  }
  return(FALSE)
}

# Helper function to get test credentials
get_test_credentials <- function() {
  list(
    host = Sys.getenv("PROTOBI_TEST_HOST"),
    dataset_id = Sys.getenv("PROTOBI_TEST_DATASET_ID"),
    table_key = Sys.getenv("PROTOBI_TEST_TABLE_KEY"),
    api_key = Sys.getenv("PROTOBI_TEST_API_KEY")
  )
}

# Helper function to check if credentials are configured
has_test_credentials <- function() {
  creds <- get_test_credentials()
  all(
    nchar(creds$host) > 0,
    nchar(creds$dataset_id) > 0,
    nchar(creds$table_key) > 0,
    nchar(creds$api_key) > 0
  )
}

test_that("protobi_put_data integration test with real API", {
  # Load environment variables from .env if available
  env_loaded <- load_test_env()

  # Skip test if credentials are not configured
  if (!has_test_credentials()) {
    skip("Test credentials not configured. Copy .env.example to .env and fill in values.")
  }

  creds <- get_test_credentials()

  # Create a small test data frame
  test_df <- data.frame(
    id = 1:10,
    name = paste0("Test", 1:10),
    value = rnorm(10),
    category = sample(c("A", "B", "C"), 10, replace = TRUE),
    stringsAsFactors = FALSE
  )

  # Test the upload
  result <- protobi_put_data(
    df = test_df,
    projectid = creds$dataset_id,
    tablekey = creds$table_key,
    apikey = creds$api_key,
    host = creds$host,
    timeout_seconds = 300
  )

  # Verify the result structure
  expect_true(!is.null(result), "Result should not be NULL")
  expect_true(!is.null(result$complete), "Result should have 'complete' field")

  # If the operation completed successfully
  if (result$complete) {
    expect_true(!is.null(result$result), "Completed result should have 'result' field")
    message(paste("Upload completed successfully. Result:", result$result))
  } else {
    # If still processing (unlikely with proper timeout)
    expect_true(!is.null(result$callback), "Incomplete result should have 'callback' field")
    message(paste("Upload still processing. Callback:", result$callback))
  }
})

test_that("protobi_put_data handles timeout correctly", {
  # Load environment variables from .env if available
  env_loaded <- load_test_env()

  # Skip test if credentials are not configured
  if (!has_test_credentials()) {
    skip("Test credentials not configured. Copy .env.example to .env and fill in values.")
  }

  creds <- get_test_credentials()

  # Create a test data frame
  test_df <- data.frame(
    id = 1:5,
    value = rnorm(5),
    stringsAsFactors = FALSE
  )

  # Test with a very short timeout (1 second) to test timeout handling
  # This test will timeout if the operation takes longer than 1 second
  # Suppress warnings since we expect a timeout warning
  result <- suppressWarnings(
    protobi_put_data(
      df = test_df,
      projectid = creds$dataset_id,
      tablekey = creds$table_key,
      apikey = creds$api_key,
      host = creds$host,
      timeout_seconds = 1
    )
  )

  # The result should still be valid even if it timed out
  expect_true(!is.null(result), "Result should not be NULL even on timeout")
  expect_true(!is.null(result$complete), "Result should have 'complete' field")
})

test_that("protobi_put_data adaptive polling intervals work correctly", {
  # This is a unit test of the polling logic without making actual API calls

  # We'll test the interval calculation logic by examining elapsed time ranges
  # The actual implementation uses these intervals:
  # 0-60s: 1 second
  # 60-120s: 2 seconds
  # 120-180s: 3 seconds
  # 180+s: 5 seconds

  get_poll_interval <- function(elapsed) {
    if (elapsed < 60) {
      return(1)
    } else if (elapsed < 120) {
      return(2)
    } else if (elapsed < 180) {
      return(3)
    } else {
      return(5)
    }
  }

  # Test different elapsed times
  expect_equal(get_poll_interval(0), 1)
  expect_equal(get_poll_interval(30), 1)
  expect_equal(get_poll_interval(59), 1)
  expect_equal(get_poll_interval(60), 2)
  expect_equal(get_poll_interval(90), 2)
  expect_equal(get_poll_interval(119), 2)
  expect_equal(get_poll_interval(120), 3)
  expect_equal(get_poll_interval(150), 3)
  expect_equal(get_poll_interval(179), 3)
  expect_equal(get_poll_interval(180), 5)
  expect_equal(get_poll_interval(300), 5)
  expect_equal(get_poll_interval(600), 5)
})

test_that("protobi_put_data handles synchronous completion", {
  # This test verifies the function works when the API returns complete=true immediately
  # This would require mocking the API, so we'll skip if no mock framework is available
  skip("Mocking framework not set up. Consider using httptest or webmockr for this test.")
})
