# protobi-r
R library to import/export data between R and Protobi

To build the package, clone the repository and issue the command 

```
R CMD INSTALL --build --preclean protobiR
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