% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/protobi.R
\name{protobi_get_data}
\alias{protobi_get_data}
\title{Get Data Function}
\usage{
protobi_get_data(
  projectid,
  tablekey,
  apikey,
  host = "https://app.protobi.com",
  formats = FALSE,
  titles = FALSE
)
}
\arguments{
\item{projectid}{A character. Protobi project identifier.}

\item{tablekey}{A character. The key of your Protobi data table.}

\item{apikey}{A character. The APIKEY from your account profile, https://app.protobi.com/account.}

\item{host}{Application host, default is https://app.protobi.com, or use https://rtanalytics.sermo.com for SERMO}

\item{formats}{Optionally download and apply value formats as factors}

\item{titles}{Optionally download and apply variable labels as column titles}
}
\description{
This function returns an R data frame representing the data in Protobi based on the parameters provided.
}
\keyword{protobi}
