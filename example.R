# Install devtools, if not already installed
# install.packages("devtools")
devtools::install_github("protobi/protobi-r")

HOST <- 'https://app.protobi.com'
PROJECTID <- '5b4cc4407bd7210003e2ed61'


data <- protobi_get_data(PROJECTID, 'main', APIKEY, HOST)
names(data)

write.csv(data, tmp, na="", row.names=TRUE)
protobi_put_data(data, PROJECTID, 'test', APIKEY, HOST)