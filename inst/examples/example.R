# install devtools
install.packages("devtools")

# load protobi-r
devtools::install_github("protobi/protobi-r")
library(protobi)

PROJECT_ID <- "5887b7494a470200030ff479"
TABLE_KEY <- "main"
API_KEY <- "6447a499-e710-4388-b94e-3ecf6e4bbeef"

data <- protobi_get_data(PROJECT_ID, TABLE_KEY, API_KEY)
protobi_put_data(data, PROJECT_ID, TABLE_KEY, API_KEY)

titles <- protobi_get_titles(PROJECTID, APIKEY)
format <- protobi_get_formats(PROJECTID, APIKEY)
data_format <- protobi_apply_titles (data_titles,  titles)
