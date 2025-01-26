library(testthat)
library(mltable)  # Load the mltable package which contains the teamstate dataset

test_that("corr_level1 calculates correlation matrix correctly", {
  data <- teamstate

  var_list <- list(
    var1 = 3,
    var2 = 4,
    var3 = 5:14,
    var4 = 15:24,
    var5 = 25:28
  )

  result <- corr_level1(data,
                        var_list,
                        var_labels = c("Gender", "Age", "Positive Affect",
                                        "Negative Affect", "Psychological Safety"))

  expect_true(is.data.frame(result))
  expect_equal(ncol(result), length(var_list) + 3)  # add 3 for Mean, SD, and Cronbach's alpha, exclude 1 column
  expect_equal(colnames(result), c("Mean", "SD", "Cronbach's alpha", "Gender", "Age", "Positive Affect",
                                   "Negative Affect", "Psychological Safety"
                                   ))
})

test_that("corr_level1 handles non-numeric columns correctly", {
  data <- teamstate

  var_list <- list(
    var1 = "Team",  # Assuming Gender is a non-numeric column in teamstate
    var2 = 4,
    var3 = 5:14,
    var4 = 15:24,
    var5 = 25:28
  )

  expect_error(corr_level1(data, var_list,
                           var_labels = c("Team", "Age", "Positive Affect",
                                          "Negative Affect", "Psychological Safety")),
                           "All columns used for calculating new variables must be numeric.")
})
