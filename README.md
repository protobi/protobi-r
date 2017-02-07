# protobi-r
R library to import/export data between R and Protobi

To build the package, clone the repository and issue the command 

```
R CMD INSTALL --build --preclean protobiR

```

To install this package, in the R command prompt issue the following command

```
install.packages("PATH_TO_LOCAL_GIT_REPO/protobiR_0.1.0.tgz", repos = NULL, type = .Platform$pkgType)

```

to create an R dataframe with data, frame and titles, use the following code

```
data <- protobi.get_data(PROJECTID, TABLEKEY, APIKEY)
format <- protobi.get_formats(PROJECTID, APIKEY)
titles <- protobi.get_titles(PROJECTID, APIKEY)

```
to add the titles metadata to the R dataframe

```
data_titles <- protobi.apply_formats (data, format)
data_format <- protobi.apply_titles (data_titles,  titles)

```