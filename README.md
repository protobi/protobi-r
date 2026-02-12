# protobi-r
R library to import/export data between R and Protobi.

Survey datasets are never final, there's always some cleaning, reshaping, 
additional variables, to create, etc.  
While you can do many or even all of these in Protobi itself, 
if R is your preferred language  you may prefer to work in R.

This utility makes it easy to download data from Protobi as a dataframe,
attach variable labels and value formats as titles and factors, 
and upload the revised dataframe back to Protobi.


## Install the package

You can install the protobi library directly from GitHub using [`devtools`](https://github.com/r-lib/devtools).
In the R command prompt issue the following command:
```R
# Install devtools, if not already installed
# install.packages("devtools")
devtools::install_github("protobi/protobi-r")
```

then load the library
```R
library(protobi)
```

## Parameters

* Get the PROJECTID from your Protobi project url, e.g. `https://app.protobi.com/v3/datasets/5386226fa0caa60200000003`
* Get the TABLEKEY from the key of your Protobi data table
* Get the APIKEY from your account profile, https://app.protobi.com/account



## Use
To download data from a Protobi project to an R dataframe:
```R
data <- protobi_get_data(PROJECTID, TABLEKEY, APIKEY, host='https://app.protobi.com', formats=FALSE, titles=FALSE)
```

If selected, varible labels are attached to the data frame as titles, 
and value formats are applied to the data frame as factors. 


To upload a dataframe to a Protobi project:
```R
protobi_put_data(data, PROJECTID, TABLEKEY, APIKEY)
```

To execute a remote data process in Protobi:
```R
result <- protobi_run_process(PROJECTID, TABLEKEY, APIKEY)
```

This function executes a data process configured for the specified table key and automatically polls until completion or timeout (default 5 minutes). The result contains the process output including any SQL query results or error messages.

## Example: K-Means segmentation and Principal Components Analysis

Here's a simple example to calculate candidate k-means segmentations and principal components analysis,
based on battery of attitudinal questions **Q14a-m**
```R
HOST <- 'https://app.protobi.com'                  ## or 'https://rtanalytics.sermo.com'
APIKEY <- 'xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx'    ## see [HOST]*/account for your API key
PROJECTID <- 'xxxxxxxxxxxxxxxxxxxx'                ## Unique identifier for project from project URL
INPUT_TABLE <- 'main'                              ## See Data tab under project admin for keys
OUTPUT_TABLE <- 'processed' 


install.packages("devtools")                        # Install devtools, if not already installed
devtools::install_github("protobi/protobi-r")       # Install protobi-r, if not already installed
library(protobi)


# Download data from project
data <- protobi_get_data(PROJECTID, INPUT_TABLE, APIKEY, host=HOST)


# Create a data frame with selected columns for analysis
basis <- cbind.data.frame(
    data$Q14a,
    data$Q14b,
    data$Q14c,
    data$Q14d,
    data$Q14e,
    data$Q14f,
    data$Q14g,
    data$Q14h,
    data$Q14i,
    data$Q14j,
    data$Q14k,
    data$Q14l,
    data$Q14m
)

# K-Means cluster analysis
    res2 <- kmeans(basis, 2, iter.max=100)
    res3 <- kmeans(basis, 3, iter.max=100)
    res4 <- kmeans(basis, 4, iter.max=100)
    res5 <- kmeans(basis, 5, iter.max=100)

# Attach k-means cluster membership to original data
    data$cluster2 = res2$cluster
    data$cluster3 = res3$cluster
    data$cluster4 = res4$cluster
    data$cluster5 = res5$cluster

# Principal components analysis
    pres <- prcomp(basis)
    pred <- predict(pres, basis)

# Attach principal component scores to original data
    data$pca1 <- pred[, c(1)]
    data$pca2 <- pred[, c(2)]

# Upload data file back to project
protobi_put_data(data, PROJECTID, OUTPUT_TABLE, APIKEY, host='https://rtanalytics.sermo.com')
```

At this point there will be a new data table in the project, with additional columns:
  *  **cluster2**,   // candidate 2-cluster solution
  *  **cluster3**,   // candidate 3-cluster solution 
  *  **cluster4**,   // candidate 4-cluster solution 
  *  **cluster5**,   // candidate 5-cluster solution
    
and 

  *  **pca1**        // first principal component 
  *  **pca2**.       // first principal component 
    
You can refer to the R output for more detailed results, such as factor loading, etc.

Set the new table to be primary table for the project, and you can add these new columns to the dashboard.

## Contribute
To build the package, clone the repository, and from the project root directory issue the command:

```bash
R CMD INSTALL --build --preclean .
```

To install this package locally, in the R command prompt issue the following command

```R
devtools::install("PATH_TO_LOCAL_GIT_REPO")
```
