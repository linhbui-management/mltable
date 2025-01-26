library(testthat)
library(mltable)  # Load the mltable package which contains the teamstate dataset

test_that("corr_level2 calculates correlation matrix correctly", {
  data <- teamstate

  var_list <- list(
    var1 = 5:14,
    var2 = 15:24,
    var3 = 25:28
  )

  result <- corr_level2(data, var_list, groupid = "Team", var_labels = c("Team PA", "Team NA", "Team PS"))

  expect_true(is.data.frame(result))
  expect_equal(ncol(result), length(var_list) + 4)  # 4 for Mean, SD, Cronbach's alpha, Rwg.j
  expect_equal(colnames(result), c("Mean", "SD", "Cronbach's Alpha",
                                   "rwg.j","Team PA", "Team NA", "Team PS"))
})


