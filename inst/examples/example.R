# install packages
install.packages("devtools", repos="http://cran.r-project.org")
install.packages("Hmisc", repos="http://cran.r-project.org")
install.packages("jsonlite", repos="http://cran.r-project.org")
install.packages("httr", repos="http://cran.r-project.org")

# Load libraries
library(devtools)
library(Hmisc)
library(jsonlite)
library(httr)

# load protobi-r
install_github("protobi/protobi-r")
library(protobi)

PROJECT_ID <- "5887b7494a470200030ff479"
TABLE_KEY <- "main"
API_KEY <- "6447a499-e710-4388-b94e-3ecf6e4bbeef"

data <- protobi.get_data(PROJECT_ID, TABLE_KEY, API_KEY)
protobi.put_data(data, PROJECT_ID, TABLE_KEY, API_KEY)

titles <- protobi.get_titles(PROJECTID, APIKEY)
format <- protobi.get_formats(PROJECTID, APIKEY)
data_format <- protobi.apply_titles (data_titles,  titles)
