
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

  if(formats) {
    df <- protobi.apply_formats(df, protobi.get_formats(PROJECTID, APIKEY))
  }
  if(titles) {
    df <- protobi.apply_titles(d, protobi.get_titles(PROJECTID, APIKEY))
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
#' @param host A character.
#' @return An httr response objec
#' @export
protobi_put_data <- function(df, projectid, tablekey, apikey, host="https://app.protobi.com") {
  # Create a path for temporary output
  temp_path <- tempfile()
  # Ensure that temporary data is removed after protobi_put_data exits
  on.exit(tryCatch(unlink(temp_path), error=function(e) {}))

  utils::write.csv(df, temp_path, na="", row.names=TRUE)
  uri <- paste0(host, "/api/v3/dataset/", projectid, "/data/", tablekey, "?apiKey=", apikey)
  message(uri)
  httr::POST(uri, body=list(file=httr::upload_file(temp_path, "text/csv")))
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
protobi_get_formats <- function(projectid, apikey) {
  uri <- paste0(
      "https://app.protobi.com/api/v3/dataset/", projectid,
      "/formats?apiKey=", apikey
  )
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
protobi_get_titles <- function(projectid,  apikey) {
  uri <- paste0(
    "https://app.protobi.com/api/v3/dataset/", projectid,
    "/titles?apiKey=", apikey
  )
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
#' Given the data and titles, this function assigns the tile (label) metadata to the R dataframe columns.
#'
#' @param df A data.frame.
#' @param titles A list with title metadata as returned from protobi_get_titles
#' @return df with metadata attached.
#' @keywords protobi
#' @export
protobi_apply_titles <- function(df, titles) {
  protobi_apply_meta(df, titles, function(col) {
    col_data <- df[[col]]
    Hmisc::label(col_data) <- titles[[col]]
    col_data
  })
}
