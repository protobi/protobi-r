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

## Parameters

* Get the PROJECTID from your Protobi project url, e.g. `https://app.protobi.com/v3/datasets/5386226fa0caa60200000003`
* Get the TABLEKEY from the key of your Protobi data table
* Get the APIKEY from your account profile, https://app.protobi.com/account


## Use
To download data from a Protobi project to an R dataframe:
```R
data <- protobi_get_data(PROJECTID, TABLEKEY, APIKEY)
```

To download the variable titles and value formats:
```R
titles <- protobi_get_titles(PROJECTID, APIKEY)
format <- protobi_get_formats(PROJECTID, APIKEY)
```

To add the variable titles to the R dataframe:
```R
data_titles <- protobi_apply_formats (data, format)
```

To apply the value formats as factors:
```R
data_format <- protobi_apply_titles (data_titles,  titles)
```

To upload a dataframe to a Protobi project:
```R
protobi_put_data(data, PROJECTID, TABLEKEY, APIKEY)
```

## Contribute
To build the package, clone the repository, and from the project root directory issue the command:

```bash
R CMD INSTALL --build --preclean .
```

To install this package locally, in the R command prompt issue the following command

```R
devtools::install("PATH_TO_LOCAL_GIT_REPO")
```
