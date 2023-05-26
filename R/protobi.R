
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
#' @param filename Optional name of file, defaults to "data.csv"
#' @return An httr response object
#' @export
protobi_put_data <- function(df, projectid, tablekey, apikey, host="https://app.protobi.com", type="data", filename="data.csv") {
  # Create a path for temporary output
  temp_path <- tempfile()
  # Ensure that temporary data is removed after protobi_put_data exits
  on.exit(tryCatch(unlink(temp_path), error=function(e) {}))

  utils::write.csv(df, temp_path, na="", row.names=TRUE)
  uri <- paste0(host, "/api/v3/dataset/", projectid, "/data/", tablekey, "?apiKey=", apikey)
  message(uri)
  httr::POST(uri, body=list(file=httr::upload_file(temp_path, "text/csv"), type=type, filename=filename))
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
  df
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

#' Get properties directly via URL as an R object
#'
#' protobi_get_url() returns a json-translated R object based on a user-supplied URL.
#'
#' @param url A character. URL location of requested properties.
#' @keywords protobi
#' @seealso [protobi_put_url()]
#' @return An R list or character value object. Type dependent on properties requested.
#' @export
protobi_get_url <- function(url) {

  resp <- httr::GET(url)

  httr::stop_for_status(resp, task = resp$url)
  if (!httr::has_content(resp)) {warning(paste("requested content is empty:", resp$url))}

  con <- httr::content(resp, as = "text")
  if (!jsonlite::validate(con)) {con <- jsonlite::toJSON(con)}
  obj <- jsonlite::fromJSON(con)

  return(obj)

}

#' Upload properties directly via URL
#'
#' protobi_put_url() uploads a key.value pair based on a user-supplied URL.
#'
#' @param url A character. URL location of requested properties.
#' @keywords protobi
#' @seealso [protobi_get_url()]
#' @return An httr response object
#' @export
protobi_put_url <- function(url) {

  url_encoded <- utils::URLencode(url, reserved = FALSE, repeated = FALSE)

  resp <- httr::PUT(url_encoded)

  httr::stop_for_status(resp, task = resp$url)

  return(resp)

}

#' Get properties
#'
#' protobi_get_properties() dynamically gets all supplied properties from Protobi.
#'
#' @param projectid A character. Protobi project identifier.
#' @param apikey A character. The APIKEY from your account profile, https://app.protobi.com/account.
#' @param execkey A character. The key of your Protobi executable process.
#' @param propertykey A character. Accepts valid (not blank, NULL, or NA) non-nested lists, vectors, or character values of property key(s). If not supplied, returns all properties.
#' @param host URL, defaults to "https://app.protobi.com"
#' @seealso [protobi_put_properties()]
#' @return An R list or character value object. Type dependent on properties requested.
#' @export
protobi_get_properties <- function(projectid, apikey, execkey, propertykey = NULL, host = "https://app.protobi.com") {

  if (is.null(propertykey)) {

    url <- paste0(host, "/api/v3/dataset/", projectid, "/data/", execkey, "/properties", "?apiKey=", apikey)
    message(url)
    message("returning all properties")
    obj <- protobi_get_url(url)

  }

  if(!is.null(propertykey)) {

    if(is.list(propertykey) & purrr::pluck_depth(propertykey) > 2) {stop("'propertykey' cannot be a nested list")}
    if(purrr::some(propertykey, function(x) x == "" | is.null(x) | is.na(x))) {stop("'propertykey' cannot have blank, NULL, or NA values")}

    ls <- as.list(propertykey)
    names(ls) <- propertykey

    root <- paste0(host, "/api/v3/dataset/", projectid, "/data/", execkey, "/properties", "?apiKey=", apikey, "&key=")
    dest <- paste(names(ls), "", sep=" ")
    message(root)
    message(dest)

    ls <- purrr::map(ls, function(x) paste0(root, x))
    obj <- purrr::map(ls, function(x) protobi_get_url(x))
    obj <- purrr::list_flatten(obj, name_spec = "{outer}.{inner}")

  }

  return(obj)


}

#' Upload properties
#'
#' protobi_put_properties() dynamically uploads all supplied properties (as list key.value pairs) to Protobi.
#'
#' @param projectid A character. Protobi project identifier.
#' @param apikey A character. The APIKEY from your account profile, https://app.protobi.com/account.
#' @param execkey A character. The key of your Protobi executable process.
#' @param propertykeyvalue A character. Accepts valid (not blank, NULL, or NA) non-nested named lists of property key.value pair(s).
#' @param host URL, defaults to "https://app.protobi.com"
#' @seealso [protobi_get_properties()]
#' @return An httr response object
#' @export
protobi_put_properties <- function(projectid, apikey, execkey, propertykeyvalue, host = "https://app.protobi.com") {

  if(!is.list(propertykeyvalue) | (is.list(propertykeyvalue) & length(names(propertykeyvalue)) == 0)) {stop("'propertykeyvalue' must be a named list")}
  if(purrr::pluck_depth(propertykeyvalue) > 2) {stop("'propertykeyvalue' cannot be a nested list")}
  if(purrr::some(lengths(propertykeyvalue), function(x) x > 1)) {stop("'propertykeyvalue' must have only key value pairs; no list elements with multiple values")}
  if(purrr::some(propertykeyvalue, function(x) x == "" | is.null(x) | is.na(x))) {stop("'propertykeyvalue' cannot have blank, NULL, or NA values")}
  if(purrr::some(names(propertykeyvalue), function(x) x == "")) {stop("all 'propertykeyvalue' values must have an accompanying non-blank name")}

  root <- paste0(host, "/api/v3/dataset/", projectid, "/data/", execkey, "/properties", "?apiKey=", apikey, "&key=")
  dest <- paste(names(propertykeyvalue), "", sep=" ")
  message(root)
  message(dest)

  ls <- purrr::lmap(propertykeyvalue, function(x) list(paste0(root, names(x), "&value=", x)))

  purrr::map(ls, function(x) protobi_put_url(x))

}

#' Execute process
#'
#' protobi_execute() executes a Protobi executable process.
#'
#' @param projectid A character. Protobi project identifier.
#' @param apikey A character. The APIKEY from your account profile, https://app.protobi.com/account.
#' @param execkey A character. The key of your Protobi executable process.
#' @param host URL, defaults to "https://app.protobi.com"
#' @return An httr response object
#' @export
protobi_execute <- function(projectid, apikey, execkey, host = "https://app.protobi.com") {

  url <- paste0(host, "/api/v3/dataset/", projectid, "/data/", execkey, "/run", "?apiKey=", apikey)
  message(url)

  resp <- httr::PUT(url)
  httr::stop_for_status(resp, task = resp$url)

  return(resp)

}

#' Get data table details
#'
#' protobi_get_table_details() returns details of all data tables associated with a Protobi project's schema (default) or primary-table.
#'
#' @param projectid A character. Protobi project identifier.
#' @param apikey A character. The APIKEY from your account profile, https://app.protobi.com/account.
#' @param scopekey A character. Defaults to "schema", can also be "primary". Gathers either all schema-table names or all primary-table names.
#' @param host URL, defaults to "https://v4.protobi.com"
#' @param only_names TRUE/FALSE, defaults to FALSE. Use TRUE to return only data table names. Optionally use 'prune' in tandem to filter result.
#' @param prune Optional stringr-formatted pattern. Pattern match data table names to remove from result. only_names must be TRUE to use.
#' @return An R data frame
#' @export
protobi_get_table_details <- function(projectid, apikey, scopekey = "schema", host = "https://v4.protobi.com", only_names = FALSE, prune = NULL) {

  if (!scopekey %in% c("schema", "primary")) {stop("'scopekey' argument must be one of: 'schema' (default) or 'primary'")}
  if (!is.null(prune) & !only_names) {stop("'prune' argument can only be used if 'only_names' = TRUE")}

  if (scopekey == "primary") {

    if(host != "https://app.protobi.com") {
      host <- "https://app.protobi.com"
      cat("switching host to https://app.protobi.com; v3 to access", scopekey, fill = TRUE)
    }

    url <- paste0(host, "/api/v3/", "dataset", "/", projectid, "/tables", "?apiKey=", apikey)
    message(url)
    cat("returning current tables in primaryTable", fill = TRUE)
    if (only_names) {cat(paste0("returning only table names; pruned: '", prune, "'"), fill = TRUE)}
    obj <- protobi_get_url(url)
    obj <- dplyr::rename(obj, table_name = key)

    if (only_names) {
      obj <- dplyr::filter(obj, stringr::str_detect(type, "data"))
      obj <- dplyr::select(obj, table_name)
      if(!is.null(prune)) {obj <- dplyr::filter(obj, !stringr::str_detect(table_name, prune))}
    }
  }

  if (scopekey == "schema") {
    if(host != "https://v4.protobi.com") {
      host <- "https://v4.protobi.com"
      cat("switching host to https://v4.protobi.com; v4 to access", scopekey, fill = TRUE)
    }

    url <- paste0(host, "/api/v4/", "project", "/", projectid, "/tables", "?apiKey=", apikey)
    message(url)
    cat("returning all tables in schema", fill = TRUE)
    if (only_names) {cat(paste0("returning only table names; pruned: '", prune, "'"), fill = TRUE)}

    obj <- protobi_get_url(url)$rows
    obj <- dplyr::filter(obj, !stringr::str_detect(table_name, "_keys$|_rejects$"))

    if (only_names) {
      obj <- dplyr::select(obj, table_name)
      if(!is.null(prune)) {obj <- dplyr::filter(obj, !stringr::str_detect(table_name, prune))}
    }
  }

  output <- as.data.frame(obj)

  return(output)
}
