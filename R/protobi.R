#install.packages("jsonlite", repos="http://cran.r-project.org")
#library(jsonlite)
#library (Hmisc)

#' Get Data Function
#'
#' This function returns an R data frame representing the data in Protobi based on the parameters provided.
#' @param PROJECTID
#' @param TABLEKEY
#' @param APIKEY
#' @keywords protobi
#' protobi.get_data()
protobi.get_data <- function(PROJECTID, TABLEKEY, APIKEY){
  a <- paste("https://app.protobi.com/api/v3/dataset/", PROJECTID , sep = "")
  a <- paste(a, "/data/", TABLEKEY , sep = "")
  a <- paste(a, "/csv?apiKey=" , sep = "")
  a <- paste(a, APIKEY, sep = "")
cat(a)
  dataDF <- utils::read.csv(a)
  return (dataDF)
}

protobi.put_data <- function(DATAFRAME, PROJECTID, TABLEKEY, APIKEY, TMPFILE="/tmp/RData.csv", HOST="https://app.protobi.com") {
  utils::write.csv(DATAFRAME, TMPFILE, na="", row.names=FALSE);
  uri <- paste(HOST, "/api/v3/dataset/", PROJECTID, "/data/", TABLEKEY, "apiKey=", APIKEY, sep="");
  res <- httr::POST(uri, body=list(y=httr::upload_file(TMPFILE,"text/csv")))
  return(res);
}

#' Get Formats Function
#'
#' This function returns an R List representing the Format metadata in Protobi based on the parameters provided.
#' @param PROJECTID
#' @param APIKEY
#' @keywords protobi
#' protobi.get_formats()
protobi.get_formats <- function (PROJECTID,  APIKEY){
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite is needed for this function to work. Please install it.",
    call. = FALSE)
  }

  a <- paste("https://app.protobi.com/api/v3/dataset/", PROJECTID , sep = "")
  a <- paste(a, "/formats?apiKey=" , sep = "")
  a <- paste(a, APIKEY, sep = "")
  formatsDf <- jsonlite::fromJSON(a)
  return (formatsDf)
}

#' Get Titles Function
#'
#' This function returns an R List representing the Titles metadata in Protobi based on the parameters provided.
#' @param PROJECTID
#' @param APIKEY
#' @keywords protobi
#' protobi.get_titles()
protobi.get_titles <- function (PROJECTID,  APIKEY) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("jsonlite is needed for this function to work. Please install it.",
    call. = FALSE)
  }
  a <- paste("https://app.protobi.com/api/v3/dataset/", PROJECTID , sep = "")
  a <- paste(a, "/titles?apiKey=" , sep = "")
  a <- paste(a, APIKEY, sep = "")
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
