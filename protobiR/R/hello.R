library(jsonlite)
library (Hmisc)

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
  a <- paste(a, "/data/main/csv?apiKey=" , sep = "")
  a <- paste(a, APIKEY, sep = "")
  print (a)
  dataDF <- read.csv(a)
  return (dataDF)
}

#' Get Formats Function
#'
#' This function returns an R List representing the Format metadata in Protobi based on the parameters provided.
#' @param PROJECTID
#' @param TABLEKEY
#' @param APIKEY
#' @keywords protobi
#' protobi.get_formats()
protobi.get_formats <- function (PROJECTID, TABLEKEY, APIKEY){
  a <- paste("https://app.protobi.com/api/v3/dataset/", PROJECTID , sep = "")
  a <- paste(a, "/formats?apiKey=" , sep = "")
  a <- paste(a, APIKEY, sep = "")
  formatsDf <- fromJSON(a)
  return (formatsDf)
}

#' Get Titles Function
#'
#' This function returns an R List representing the Titles metadata in Protobi based on the parameters provided.
#' @param PROJECTID
#' @param TABLEKEY
#' @param APIKEY
#' @keywords protobi
#' protobi.get_titles()
protobi.get_titles <- function (PROJECTID, TABLEKEY, APIKEY) {
  a <- paste("https://app.protobi.com/api/v3/dataset/", PROJECTID , sep = "")
  a <- paste(a, "/titles?apiKey=" , sep = "")
  a <- paste(a, APIKEY, sep = "")
  titlesDf <- fromJSON(a)
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
  data_df$package <- factor(data_df$package, levels = format_df$package$levels, labels=format_df$package$labels)
  data_df$brand <- factor(data_df$brand, levels = format_df$brand$levels, labels=format_df$brand$labels)
  data_df$price <- factor(data_df$price, levels = format_df$price$levels, labels=format_df$price$labels)
  data_df$seal <- factor(data_df$seal, levels = format_df$seal$levels, labels=format_df$seal$labels)
  data_df$money <- factor(data_df$money, levels = format_df$money$levels, labels=format_df$money$labels)
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
    print(i)
    label(data_df[colNames[i]]) <- names_df[colNames[i]]
  }
  return (data_df)
}
