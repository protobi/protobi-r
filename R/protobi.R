#install.packages("jsonlite", repos="http://cran.r-project.org")
#library(jsonlite)
#library (Hmisc)

#' Get Data Function
#'
#' This function returns an R data frame representing the data in Protobi based on the parameters provided.
#' @param projectid
#' @param tablekey
#' @param apikey
#' @keywords protobi
#' protobi.get_data()
protobi.get_data <- function(projectid, tablekey, apikey){
  a <- paste("https://app.protobi.com/api/v3/dataset/", projectid , sep = "")
  a <- paste(a, "/data/", tablekey , sep = "")
  a <- paste(a, "/csv?apiKey=" , sep = "")
  a <- paste(a, apikey, sep = "")
cat(a)
  dataDF <- utils::read.csv(a)
  return (dataDF)
}

protobi.put_data <- function(df, projectid, tablekey, apikey, tmpfile="/tmp/RData.csv", host="https://app.protobi.com") {
  utils::write.csv(df, tmpfile, na="", row.names=FALSE);
  uri <- paste(host, "/api/v3/dataset/", projectid, "/data/", tablekey, "apiKey=", apikey, sep="");
  res <- httr::POST(uri, body=list(y=httr::upload_file(tmpfile,"text/csv")))
  return(res);
}

#' Get Formats Function
#'
#' This function returns an R List representing the Format metadata in Protobi based on the parameters provided.
#' @param projectid
#' @param apikey
#' @keywords protobi
#' protobi.get_formats()
<<<<<<< HEAD
protobi.get_formats <- function (PROJECTID,  APIKEY){
  a <- paste("https://app.protobi.com/api/v3/dataset/", PROJECTID , sep = "")
=======
protobi.get_formats <- function (projectid,  apikey){
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite is needed for this function to work. Please install it.",
    call. = FALSE)
  }

  a <- paste("https://app.protobi.com/api/v3/dataset/", projectid , sep = "")
>>>>>>> 79136b5... Use lowercase argument names
  a <- paste(a, "/formats?apiKey=" , sep = "")
  a <- paste(a, apikey, sep = "")
  formatsDf <- jsonlite::fromJSON(a)
  return (formatsDf)
}

#' Get Titles Function
#'
#' This function returns an R List representing the Titles metadata in Protobi based on the parameters provided.
#' @param projectid
#' @param apikey
#' @keywords protobi
#' protobi.get_titles()
protobi.get_titles <- function (projectid,  apikey) {
  a <- paste("https://app.protobi.com/api/v3/dataset/", projectid , sep = "")
  a <- paste(a, "/titles?apiKey=" , sep = "")
  a <- paste(a, apikey, sep = "")
  titlesDf <- jsonlite::fromJSON(a)
  return (titlesDf)
}

#' Apply Formats Function
#'
#' Given the data and format, this function replaces the values in the dataframe column with the format metada values.
#' @param data_df  #R dataframe
#' @param format_df  #format metadata
#' @keywords protobi
#' protobi.get_formats()
protobi.apply_formats <- function(data_df, format_df){
  colNames <- colnames(data_df)
  for (i in 1:length(colNames)) {
    tempFormat <- format_df[[colNames[i]]]
    if (!is.null(tempFormat)){
      data_df[[colNames[i]]] <- factor(data_df[[colNames[i]]], levels = tempFormat$levels, labels=tempFormat$labels)
    }
  }
  return(data_df)
}

#' Apply Titles Function
#'
#' Given the data and format, this function assigns the tile (label) metadata to the R dataframe columns.
#' @param data_df  #R dataframe
#' @param names_df  #format metadata
#' @keywords protobi
#' protobi.get_titles()
protobi.apply_titles <- function (data_df, names_df){
  colNames <- colnames(data_df)
  for (i in 1:length(colNames)) {
    if (!is.null(names_df[colNames[i]])){
      Hmisc::label(data_df[colNames[i]]) <- names_df[colNames[i]]
    }
  }
  return (data_df)
}
