#' Get Data Function
#'
#' This function returns an R data frame representing the data in Protobi based on the parameters provided.
#'
#' @param projectid A character. Protobi project identifier.
#' @param tablekey A character. The key of your Protobi data table.
#' @param apikey A character. The APIKEY from your account profile, https://app.protobi.com/account.
#' @keywords protobi
#' @export
protobi_get_data <- function(projectid, tablekey, apikey) {
  uri <- paste0(
    "https://app.protobi.com/api/v3/dataset/", projectid, "/data/", tablekey,
    "/csv?apiKey=", apikey
  )
  utils::read.csv(uri)
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

  utils::write.csv(df, temp_path, na="", row.names=FALSE)
  uri <- paste(host, "/api/v3/dataset/", projectid, "/data/", tablekey, "apiKey=", apikey, sep="")
  httr::POST(uri, body=list(y=httr::upload_file(temp_path, "text/csv")))
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
  colNames <- colnames(df)
  for (i in 1:length(colNames)) {
    tempFormat <- formats[[colNames[i]]]
    if (!is.null(tempFormat)){
      df[[colNames[i]]] <- factor(df[[colNames[i]]], levels=tempFormat$levels, labels=tempFormat$labels)
    }
  }
  df
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
  colNames <- colnames(df)
  for (i in 1:length(colNames)) {
    if (!is.null(titles[[colNames[i]]])) {
      Hmisc::label(df[colNames[i]]) <- titles[colNames[i]]
    }
  }
  df
}
