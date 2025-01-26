# mltable - Calculating and Formatting Statistics Tables for Multilevel Data <img src="logo_mltable.png" alt="logo" style="float:right; width:200px;"> 


[![Build Status](https://app.travis-ci.com/linhbui-management/mltable.svg?token=4VKpm7KznzmjKM9vcLMv&branch=main)](https://app.travis-ci.com/linhbui-management/mltable)

This R package provides tools for calculating and formatting correlation matrices for Level 1 and Level 2 data. 
It includes additional metrics such as mean, standard deviation, Cronbach's alpha, and rwg.j.

# Installation
To install the package, use the following commands in R:

## Install the devtools package if you don't already have it
# Installation Instructions

To install the `devtools` package, use the following command:

install.packages("devtools")

## Install the package from GitHub
devtools::install_github("linhbui.management/mltable")

# Usage
Here’s how to use the package:

library(mltable)

## Level 1 Correlation Matrix (e.g., individual level)
data <- teamstate
var_list <- list(
    var1 = 3,
    var2 = 4,
    var3 = 5:14,
    var4 = 15:24,
    var5 = 25:28)

  result <- corr_level1(data,
                        var_list,
                        var_labels = c("Gender", "Age", "Positive Affect",
                                        "Negative Affect", "Psychological Safety"))

print(result)>
## Level 2 Correlation Matrix (e.g., group level)
# Example usage
data <- teamstate
var_list2 <- list(
                  var1 = 5:14,
                  var2 = 15:24,
                  var3 = 25:28)

result <- corr_level2(data = teamstate,
                      var_list = var_list2,
                      groupid = "Team",
                      var_labels = c("Team PA", "Team NA", "Team Psychological Safety"),
                      rwg_scale = 7)

print(result)

# Contributing
Contributions are welcome! If you'd like to contribute, please follow these steps:

Fork the repository.

Create a new branch for your feature or bugfix.

Commit your changes.

Submit a pull request.

Please ensure your code follows the project's coding standards and includes appropriate tests.

# License
This project is licensed under the MIT License. See the LICENSE file for details.

# Contact
For questions or feedback, please contact:

Your Name: linhbui.management@gmail.com

GitHub: linhbui-management

Project Link: https://github.com/linhbui-management/mltable

# Citation
If you use the mltable package in your work, please cite it as follows:
Bui, L. (2025). mltable: A Package for Calculating and Formatting Correlation Matrices (Version 0.0.0.9000) [R package]. Retrieved from 

You can generate the citation directly in R by running: citation("mltable")

The core functionality of mltable relies on the following R packages. Please consider citing them as well:

psych: Revelle, W. (2023). psych: Procedures for Psychological, Psychometric, and Personality Research [R package]. Retrieved from https://CRAN.R-project.org/package=psych

multilevel: Bliese, P., Chen, G., Downes, P., Schepker, D., & Lang, J. (2022). Package 'multilevel' (Version 2.7) [R package]. Retrieved from https://cran.r-project.org/web/packages/multilevel/index.html

