% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/protobi.R
\name{protobi_get_table_details}
\alias{protobi_get_table_details}
\title{Get data table details}
\usage{
protobi_get_table_details(
  projectid,
  apikey,
  scopekey = "schema",
  host = "https://v4.protobi.com",
  only_names = FALSE,
  prune = NULL
)
}
\arguments{
\item{projectid}{A character. Protobi project identifier.}

\item{apikey}{A character. The APIKEY from your account profile, https://app.protobi.com/account.}

\item{scopekey}{A character. Defaults to "schema", can also be "primary". Gathers either all schema-table names or all primary-table names.}

\item{host}{URL, defaults to "https://v4.protobi.com"}

\item{only_names}{TRUE/FALSE, defaults to FALSE. Use TRUE to return only data table names. Optionally use 'prune' in tandem to filter result.}

\item{prune}{Optional stringr-formatted pattern. Pattern match data table names to remove from result. only_names must be TRUE to use.}
}
\value{
An R data frame
}
\description{
protobi_get_table_details() returns details of all data tables associated with a Protobi project's schema (default) or primary-table.
}
