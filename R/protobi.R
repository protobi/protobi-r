#' Get Data Function
#'
#' This function returns an R data frame representing the data in Protobi based on the parameters provided.
#'
#' @param projectid A character. Protobi project identifier.
#' @param tablekey A character. The key of your Protobi data table.
#' @param apikey A character. The APIKEY from your account profile, https://app.protobi.com/account.
#' @keywords protobi
#' protobi.get_data()
protobi.get_data <- function(projectid, tablekey, apikey) {
  uri <- paste0(
    "https://app.protobi.com/api/v3/dataset/", projectid, "/data/", tablekey,
    "/csv?apiKey=", apikey
  )
  cat(uri)
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
#' @param tmpfile A character.
#' @param host A character.
#' @return An httr response object
protobi.put_data <- function(df, projectid, tablekey, apikey, tmpfile="/tmp/RData.csv", host="https://app.protobi.com") {
  utils::write.csv(df, tmpfile, na="", row.names=FALSE)
  uri <- paste(host, "/api/v3/dataset/", projectid, "/data/", tablekey, "apiKey=", apikey, sep="")
  httr::POST(uri, body=list(y=httr::upload_file(tmpfile, "text/csv")))
}

#' Get Formats Function
#'
#' This function returns an R List representing the Format metadata in Protobi based on the parameters provided.
#'
#' @param projectid A character. Protobi project identifier.
#' @param apikey A character. e APIKEY from your account profile, https://app.protobi.com/account.
#' @return A list representing format metadata.
#' @keywords protobi
#' protobi.get_formats()
protobi.get_formats <- function (projectid, apikey) {
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
#' protobi.get_titles()
protobi.get_titles <- function (projectid,  apikey) {
  a <- paste("https://app.protobi.com/api/v3/dataset/", projectid, sep="")
  a <- paste(a, "/titles?apiKey=" , sep="")
  a <- paste(a, apikey, sep="")
  jsonlite::fromJSON(a)
}

#' Apply Formats Function
#'
#' Given the data and format, this function replaces the values in the dataframe column with the format metadata values.
#'
#' @param data_df A dataframe.
#' @param format_df A format metadata.
#' @return The data_df with levels adjusted according to format_df.
#' @keywords protobi
#' protobi.get_formats()
protobi.apply_formats <- function(data_df, format_df) {
  colNames <- colnames(data_df)
  for (i in 1:length(colNames)) {
    tempFormat <- format_df[[colNames[i]]]
    if (!is.null(tempFormat)){
      data_df[[colNames[i]]] <- factor(data_df[[colNames[i]]], levels=tempFormat$levels, labels=tempFormat$labels)
    }
  }
  data_df
}

#' Apply Titles Function
#'
#' Given the data and format, this function assigns the tile (label) metadata to the R dataframe columns.
#'
#' @param data_df A data.frame.
#' @param names_df A format metadata.
#' @return data_df with metadata attached.
#' @keywords protobi
#' protobi.get_titles()
protobi.apply_titles <- function (data_df, names_df) {
  colNames <- colnames(data_df)
  for (i in 1:length(colNames)) {
    if (!is.null(names_df[colNames[i]])){
      Hmisc::label(data_df[colNames[i]]) <- names_df[colNames[i]]
    }
  }
  data_df
}
