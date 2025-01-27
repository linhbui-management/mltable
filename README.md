# mltable - Calculating and Formatting Tables for Multilevel Data <img src="logo_mltable.png" align="right" width="220"/>

[![Build Status](https://app.travis-ci.com/linhbui-management/mltable.svg?token=4VKpm7KznzmjKM9vcLMv&branch=main)](https://app.travis-ci.com/linhbui-management/mltable)

This R package provides tools for calculating and formatting correlation matrices for Level 1 and Level 2 data. 
It includes additional metrics such as mean, standard deviation, Cronbach's alpha, and rwg.j.

# Installation
To install the package, use the following commands in R:

```r
library(devtools)
devtools::install_github("linhbui.management/mltable")
```
# Usage
Here’s how to use the package:


## Level 1 Correlation Matrix (e.g., individual level)

```r
library(mltable)
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
```

## Level 2 Correlation Matrix (e.g., group level)

```r
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
```

# Contributing
Contributions are welcome! If you'd like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Commit your changes.
4. Submit a pull request.
5. Please ensure your code follows the project's coding standards and includes appropriate tests.

# License
This project is licensed under the MIT License. See the LICENSE file for details.

# Contact
For questions or feedback, please contact:

Linh Bui.
Email: linhbui.management@gmail.com
GitHub: linhbui-management
Project Link: https://github.com/linhbui-management/mltable

# Citation

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14744310.svg)](https://doi.org/10.5281/zenodo.14744310)

If you use the mltable package in your work, please cite it as follows:

```r
Bui, L. (2025). mltable: An R package for calculating and formatting tables for multilevel data.
https://doi.org/10.5281/zenodo.14744310. Retrieved from https://github.com/linhbui-management/mltable.git
```

The core functionality of `mltable` relies on R packages `psych` and `multilevel`. 
Please consider citing them as well:

```
Revelle, W. (2023). psych: Procedures for Psychological, Psychometric, and Personality Research [R package]. 
Retrieved from https://CRAN.R-project.org/package=psych

Bliese, P., Chen, G., Downes, P., Schepker, D., & Lang, J. (2022). Package 'multilevel' (Version 2.7) [R package]. 
Retrieved from https://cran.r-project.org/web/packages/multilevel/index.html
```

