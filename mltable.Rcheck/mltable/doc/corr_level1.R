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
library(psych)  # For Cronbach's alpha calculation

# Load built-in dataset
file_path <- system.file("extdata", "teamstate.csv", package = "mltable")
teamstate <- read.csv(file_path)

## -----------------------------------------------------------------------------
var_list <- list( 
  var1 = 3,         # Single column (Gender item) 
  var2 = 4,         # Single column (Age item) 
  var3 = 5:14,      # Columns 5-14 (PosAffect items) 
  var4 = 15:24,     # Columns 15-24 (NegAffect items) 
  var5 = 25:28      # Columns 25-28 (PsySafety items) 
) 

## -----------------------------------------------------------------------------
result <- corr_table(
  data = teamstate,
  var_list = var_list,
  var_labels = c("Gender", "Age", "Positive Affect", "Negative Affect", "Psychological Safety")
)


## -----------------------------------------------------------------------------
corr_table( 
  teamstate, var_list, 
  triangle = "upper", 
  digits = 2, 
  lead.decimal = TRUE  # Keep leading zeros (e.g., 0.123) 
) 

## -----------------------------------------------------------------------------
corr_table( 
  teamstate, var_list, 
  mean = FALSE, 
  alpha = FALSE 
) # Exclude mean and Cronbach's alpha 

## -----------------------------------------------------------------------------
write.csv(result, "correlation_table.csv", row.names = TRUE) 

