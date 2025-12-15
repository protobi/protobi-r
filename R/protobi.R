
#' Utility to read zipped CSV from URL
#'
#' This function reads a CSV from a URL in GZip format and returns a data frame
#' @param uri   Address of CSV
#' @export
protobi_read_csv_gzip <- function(uri) {
  con <- gzcon(url(uri))
  txt <- readLines(con, warn=FALSE)
  tcn <- textConnection(txt)
  return(read.csv(tcn))
}


#' Get Data Function
#'
#' This function returns an R data frame representing the data in Protobi based on the parameters provided.
#'
#' @param projectid A character. Protobi project identifier.
#' @param tablekey A character. The key of your Protobi data table.
#' @param apikey A character. The APIKEY from your account profile, https://app.protobi.com/account.
#' @param host  Application host, default is https://app.protobi.com, or use https://rtanalytics.sermo.com for SERMO
#' @param formats  Optionally download and apply value formats as factors
#' @param titles   Optionally download and apply variable labels as column titles
#' @keywords protobi
#' @export
protobi_get_data <- function(projectid, tablekey, apikey, host="https://app.protobi.com", formats=FALSE, titles=FALSE) {

  uri <- paste0(host, "/api/v3/dataset/", projectid, "/data/", tablekey, "/csv?apiKey=", apikey)
  message(uri)
  df <- protobi_read_csv_gzip(uri)
  httr::set_config(httr::config(ssl_verifypeer = 0L))

  if(formats) {
    protobi_apply_formats(df, protobi_get_formats(projectid, apikey, host))
  }
  if(titles) {
    df <- protobi_apply_titles(df, protobi_get_titles(projectid, apikey, host))
  }
  df
}

#' Upload Data Function
#'
#' This function uploads data.frame content to Protobi
#'
#' @param df A data.frame to uploaded to Protobi.
#' @param projectid A character. Protobi project identifier.
#' @param tablekey A character. The key of your Protobi data table.
#' @param apikey A character. The APIKEY from your account profile, https://app.protobi.com/account.
#' @param host URL, defaults to "https://app.protobi.com"
#' @param type Type of data, defaults to "data"
#' @param filename Optional name of file, defaults to "data.csv"
#' @param timeout_seconds Maximum time in seconds to wait for async task completion, defaults to 300 (5 minutes)
#' @return A list with elements: complete (boolean), result (url when complete=true), and possibly callback (url) or message (string) when complete=false
#' @export
protobi_put_data <- function(df, projectid, tablekey, apikey, host="https://app.protobi.com", type="data", filename="data.csv", timeout_seconds=300) {
  # Create a path for temporary output
  temp_path <- tempfile()
  # Ensure that temporary data is removed after protobi_put_data exits
  on.exit(tryCatch(unlink(temp_path), error=function(e) {}))

  utils::write.csv(df, temp_path, na="", row.names=TRUE)
  uri <- paste0(host, "/api/v3/dataset/", projectid, "/data/", tablekey, "?apiKey=", apikey)
  message(uri)

  response <- httr::POST(uri, body=list(file=httr::upload_file(temp_path, "text/csv"), type=type, filename=filename), httr::config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))

  # Parse JSON response
  content <- httr::content(response, as="text", encoding="UTF-8")
  result <- jsonlite::fromJSON(content)

  # If the task is not complete and has a callback, poll until completion or timeout
  if (!is.null(result$complete) && !result$complete && !is.null(result$callback)) {
    message("Task initiated. Polling for completion...")
    start_time <- Sys.time()

    while (TRUE) {
      # Check if timeout has been exceeded
      elapsed <- as.numeric(difftime(Sys.time(), start_time, units="secs"))
      if (elapsed > timeout_seconds) {
        warning(paste("Timeout after", timeout_seconds, "seconds. Task may still be processing."))
        return(result)
      }

      # Adaptive polling interval based on elapsed time
      # 0-60s: poll every 1 second
      # 60-120s: poll every 2 seconds
      # 120-180s: poll every 3 seconds
      # 180-300s: poll every 5 seconds
      # 300+s: poll every 5 seconds
      if (elapsed < 60) {
        poll_interval <- 1
      } else if (elapsed < 120) {
        poll_interval <- 2
      } else if (elapsed < 180) {
        poll_interval <- 3
      } else {
        poll_interval <- 5
      }

      # Wait before polling
      Sys.sleep(poll_interval)

      # Poll the callback URL
      # Handle both absolute and relative callback URLs
      callback <- result$callback
      if (!grepl("^https?://", callback)) {
        # Relative URL, prepend host
        callback_url <- paste0(host, callback, "?apiKey=", apikey)
      } else {
        # Absolute URL
        callback_url <- paste0(callback, "?apiKey=", apikey)
      }
      poll_response <- httr::GET(callback_url, httr::config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
      poll_content <- httr::content(poll_response, as="text", encoding="UTF-8")
      result <- jsonlite::fromJSON(poll_content)

      # Check if task is complete
      if (!is.null(result$complete) && result$complete) {
        message("Task completed successfully!")
        break
      }

      # Show progress message if available
      if (!is.null(result$message)) {
        message(paste("Status:", result$message))
      }
    }
  }

  return(result)
}

#' Get Formats Function
#'
#' This function returns an R List representing the Format metadata in Protobi based on the parameters provided.
#'
#' @param projectid A character. Protobi project identifier.
#' @param apikey A character. e APIKEY from your account profile, https://app.protobi.com/account.
#' @return A list representing format metadata.
#' @keywords protobi
#' @export
protobi_get_formats <- function(projectid, apikey, host) {
  uri <- paste0(host, "/api/v3/dataset/", projectid,"/formats?apiKey=", apikey)
  message(uri)
  jsonlite::fromJSON(uri)
}

#' Get Titles Function
#'
#' This function returns an R List representing the Titles metadata in Protobi based on the parameters provided.
#'
#' @param projectid A character. Protobi project identifier.
#' @param apikey A character. e APIKEY from your account profile, https://app.protobi.com/account.
#' @return A list representing titles metadata
#' @keywords protobi
#' @export
protobi_get_titles <- function(projectid,  apikey, host) {
  uri <- paste0(host, "/api/v3/dataset/", projectid, "/titles?apiKey=", apikey)
  message(uri)
  jsonlite::fromJSON(uri)
}


#' Internal helper function used to apply metadata to df
#'
#' Given df, metadata and updating function return df with updated columns
#' @param df A data.frame.
#' @param metadata A list.
#' @param updater A function that takes a column name and returns corresponding data with attached metadata.
#' @return df with metadata attached.
protobi_apply_meta <- function(df, metadata, updater) {
  # Get intersection of names of metadata object and data
  cols <- intersect(
    # excluding null entries i.e. {"col": null}
    # and empty objects i.e {"col": {}}
    # This is defensive approach, and might not be necessary
    names(metadata)[lengths(metadata) != 0],
    colnames(df)
  )
  cols
  df[cols] <- lapply(cols, updater)
  df
}

#' Apply Formats Function
#'
#' Given the data and format, this function replaces the values in the dataframe column with the format metadata values.
#'
#' @param df A data.frame.
#' @param formats A list with format metadata as returned by protobi_get_formats.
#' @return The df with levels adjusted according to formats.
#' @keywords protobi
#' @export
protobi_apply_formats <- function(df, formats) {
  protobi_apply_meta(df, formats, function(col) {
    fmt <- formats[[col]]
    factor(df[[col]], levels=fmt$levels, labels=fmt$labels)
  })
}

#' Apply Titles Function
#'
#' Given the data and titles, this function assigns the title (label) metadata to the R dataframe columns.
#'
#' @param df A data.frame.
#' @param titles A list with title metadata as returned from protobi_get_titles
#' @return df with metadata attached.
#' @keywords protobi
#' @export
protobi_apply_titles <- function(df, titles) {
  df_labels <- as.data.frame(unlist(titles))
  df_labels$colname <- rownames(df_labels)

  for (i in c(1:ncol(df))) {
    col_name <- df_labels[i,2]
    col_label <- df_labels[i,1]

    if (col_name %in% colnames(df)) {
      Hmisc::label(df[, col_name]) <- col_label
    }
  }
  df
}
