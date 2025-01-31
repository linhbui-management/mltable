## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE,
  message = FALSE,
  options(rmarkdown.html_vignette.check_title = FALSE)
)

## -----------------------------------------------------------------------------
library(mltable)
library(multilevel)  # For rwg.j calculation
library(psych)       # For Cronbach's alpha

# Load built-in dataset
file_path <- system.file("extdata", "teamstate.csv", package = "mltable")
teamstate <- read.csv(file_path)

## -----------------------------------------------------------------------------
var_list2 <- list(
   var1 = 5:14,    # Team positive affect
   var2 = 15:24,   # Team negative affect
   var3 = 25:28    # Team psychological safety
  )

## -----------------------------------------------------------------------------
result <- corr_level2(data = teamstate,
                      var_list = var_list2,
                      groupid = "Team",  # Group identifier column
                      var_labels = c("Team PA", "Team NA", "Team PS"),
                      rwg_scale = 7,     # 7-point response scale
)

## -----------------------------------------------------------------------------
corr_level2(
  teamstate,
  var_list2,
  groupid = "Team",
  rwg_method = "median",
  rwg_scale = 7,
  lead.decimal = FALSE
)

## -----------------------------------------------------------------------------
corr_level2(
  teamstate,
  var_list2,
  groupid = "Team",
  mean = FALSE,
  alpha = FALSE,
  rwg = FALSE
)

## -----------------------------------------------------------------------------
write.csv(result, "team_level_correlations.csv", row.names = TRUE)

