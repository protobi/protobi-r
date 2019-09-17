context("protobi.apply_formats")

test_that("There is no regression in unwinded apply_formats", {
  # The old implementation
  old_protobi_apply_formats <- function(data_df, format_df) {
    colNames <- colnames(data_df)
    for (i in 1:length(colNames)) {
      tempFormat <- format_df[[colNames[i]]]
      if (!is.null(tempFormat)){
        data_df[[colNames[i]]] <- factor(data_df[[colNames[i]]], levels=tempFormat$levels, labels=tempFormat$labels)
      }
    }
    data_df
  }

  data_df_1 <- data.frame(x=c("a", "b", "c"), y=c(1, 2, 3), stringsAsFactors=FALSE)
  format_df_1 <- list(x=list(levels=c("a", "b", "c"), labels=c("a_l", "b_l", "c_l")))
  expect_identical(
    protobi_apply_formats(data_df_1, format_df_1),
    old_protobi_apply_formats(data_df_1, format_df_1)
  )

  # Should handle explicit NULLs
  format_df_2 <- list(x=list(levels=c("a", "b", "c"), labels=c("a_l", "b_l", "c_l"), y=NULL))
  expect_identical(
    protobi_apply_formats(data_df_1, format_df_2),
    old_protobi_apply_formats(data_df_1, format_df_2)
  )

  # Should handle additional labels
  format_df_3 <- list(
    x=list(levels=c("a", "b", "c"), labels=c("a_l", "b_l", "c_l")),
    z=list(levels=c("foo", "bar", "baz"), labels=c("foo_l", "bar_l", "baz_l"))
  )
  expect_identical(
    protobi_apply_formats(data_df_1, format_df_3),
    old_protobi_apply_formats(data_df_1, format_df_3)
  )
})

test_that("protobi_apply_formats sets expected levels", {
  labels <- c("a_l", "b_l", "c_l")

  result <- protobi_apply_formats(
    data.frame(x=c("a", "b", "c"), stringsAsFactors=FALSE),
    list(x=list(levels=c("a", "b", "c"), labels=labels))
  )
  expect_equal(levels(result$x), labels)
})

context("protobi.apply_titles")

test_that("There is no regression in unwinded apply_titles", {
  # The old implementation
  old_protobi_apply_titles <- function(data_df, names_df) {
    colNames <- colnames(data_df)
    for (i in 1:length(colNames)) {
      if (!is.null(names_df[[colNames[i]]])){
        Hmisc::label(data_df[colNames[i]]) <- names_df[colNames[i]]
      }
    }
    data_df
  }

  data_df_1 <- data.frame(x=c("a", "b", "c"), y=c(1, 2, 3), stringsAsFactors=FALSE)
  title_df_1 <- list(x="foo")
  expect_identical(
    protobi_apply_titles(data_df_1, title_df_1),
    old_protobi_apply_titles(data_df_1, title_df_1)
  )

  # Should handle explicit NULL
  title_df_2 <- list(x="foo", y=NULL)
  expect_identical(
    protobi_apply_titles(data_df_1, title_df_2),
    old_protobi_apply_titles(data_df_1, title_df_2)
  )

  # Should handle additional labels
  title_df_3 <- list(x="foo", z="bar")
  expect_identical(
    protobi_apply_titles(data_df_1, title_df_3),
    old_protobi_apply_titles(data_df_1, title_df_3)
  )
})

test_that("protobi_apply_title sets expected label", {
  result <- protobi_apply_titles(
    data.frame(x=c("a", "b", "c"), stringsAsFactors=FALSE),
    list(x="foo")
  )

  expect_true(
    Hmisc::label(result$x) == "foo"
  )
})
