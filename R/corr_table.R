# ' Calculate and Format Correlation Matrix
#'
#' This function calculates the correlation matrix for a given list of variables,
#' formats the results, and includes additional metrics such as mean, standard deviation,
#' and Cronbach's alpha if requested.
#'
#' @param data A data frame containing the variables specified in `var_list`.
#' @param var_list A named list of variables where each entry is either a vector of
#' column indices or column names from the `data` data frame.
#' @param type The type of correlation to compute. Options are
#' "pearson" (default), "spearman", or "kendall".
#' @param digits Integer indicating the number of decimal places to be used for
#' formatting the correlation values. Default is 3.
#' @param decimal.mark Character to be used as the decimal mark. Default is ".".
#' @param triangle A character string indicating which part of the correlation
#' matrix to display. Options are "both", "upper", or "lower" (default).
#' @param use A character string indicating how to handle missing values.
#' Options are "all.obs", "complete.obs" (listwise deletion), or
#' "pairwise.complete.obs" (pairwise deletion - default).
#' @param show_significance Logical indicating whether to display
#' significance levels. Default is TRUE.
#' @param replace_diagonal Logical indicating whether to replace the
#' diagonal values. Default is TRUE.
#' @param replacement Value to replace the diagonal values if
#' `replace_diagonal` is TRUE. Default is NA.
#' @param lead.decimal Logical indicating whether to keep leading zeros
#' before the decimal point. Default is FALSE.
#' @param var_labels An optional vector of variable labels to use in the output.
#' Default is NULL.
#' @param mean Logical indicating whether to include the mean of the variables.
#' Default is TRUE.
#' @param sd Logical indicating whether to include the standard deviation of
#' the variables. Default is TRUE.
#' @param alpha Logical indicating whether to include Cronbach's alpha for
#' the variables. Default is TRUE.
#' @importFrom stats cor cor.test
#' @importFrom utils install.packages
#' @return A formatted correlation matrix as a data frame, which can be exported
#' as a CSV file.
#'
#' @examples
#' \dontrun{
#' file_path <- system.file("extdata", "teamstate.csv", package = "mltable")
#' teamstate <- read.csv(file_path)
#' var_list <- list(
#'   var1 = 3,
#'   ver2 = 4,
#'   var2 = 5:14,
#'   var3 = 15:24,
#'   var4 = 25:28
#' )
#' result <- corr_level1(teamstate,
#'                       var_list,
#'                       var_labels = c("Gender", "Age", "Positive affect",
#'                       "Negative affect", "Psychological safety"))
#' print(result)
#' write.csv(result, file = "Correlation table individual member states.csv", row.names = TRUE)
#' }
#'
#' @seealso \code{\link{cor}}, \code{\link{cor.test}}
#' @export

corr_table <- function(data,
                        var_list,
                        type = c("pearson", "spearman", "kendall"),
                        digits = 3,
                        decimal.mark = ".",
                        triangle = c("both", "upper", "lower"),
                        use = c("all.obs", "complete.obs", "pairwise.complete.obs"),
                        show_significance = TRUE,
                        replace_diagonal = TRUE,
                        replacement = NA,
                        lead.decimal = FALSE,
                        var_labels = NULL,
                        mean = TRUE,
                        sd = TRUE,
                        alpha = TRUE) {
  # Ensure the 'psych' package is available
  if (!requireNamespace("psych", quietly = TRUE)) {
    install.packages("psych")
  }
  requireNamespace("psych")

  # Ensure the 'stats' package for cor.test is available
  if (!requireNamespace("stats", quietly = TRUE)) {
    stop("The 'stats' package is required but not available.")
  }

  # Default to "lower" if no valid option is provided
  triangle <- match.arg(triangle, choices = c("both", "upper", "lower"))
  type <- match.arg(type)
  use <- match.arg(use, choices = c("all.obs", "complete.obs", "pairwise.complete.obs"))

  # Check arguments
  stopifnot({
    is.data.frame(data)
    is.numeric(digits)
    digits >= 0
    is.logical(replace_diagonal)
    is.logical(show_significance)
    is.logical(lead.decimal)
    is.null(var_labels) || length(var_labels) == length(var_list)
    is.logical(mean)
    is.logical(sd)
    is.logical(alpha)
  })

  # Initialize an empty data frame with the correct number of rows
  if (!is.data.frame(data) || nrow(data) == 0) {
    stop("The data frame has no rows or is not a data frame.")
  }

  num_rows <- nrow(data)
  df <- data.frame(matrix(nrow = num_rows, ncol = 0))

  # Calculate new variables based on var_list
  for (new_var in names(var_list)) {
    selected_columns <- data[, var_list[[new_var]], drop = FALSE]

    # Ensure all selected columns are numeric
    if (!all(sapply(selected_columns, is.numeric))) {
      stop("All columns used for calculating new variables must be numeric.")
    }

    # Check row dimension consistency
    if (nrow(selected_columns) != num_rows) {
      stop("All columns must have the same number of rows.")
    }

    df[[new_var]] <- rowMeans(selected_columns, na.rm = TRUE)
  }

  # Transform the input data frame to a matrix
  x <- as.matrix(df)

  # Run correlation analysis using cor function
  R <- cor(x, use = use, method = type)

  # Significance levels calculation
  calculate_p_values <- function(x, method, use) {
    p.mat <- matrix(NA, ncol = ncol(x), nrow = ncol(x))
    for (i in 1:(ncol(x) - 1)) {
      for (j in (i + 1):ncol(x)) {
        test <- cor.test(x[, i], x[, j], method = method, use = use)
        p.mat[i, j] <- test$p.value
        p.mat[j, i] <- test$p.value
      }
    }
    return(p.mat)
  }

  if (show_significance) {
    p <- calculate_p_values(x, type, use)
  } else {
    p <- matrix(NA, ncol = ncol(R), nrow = nrow(R))
  }

  # Transform correlations to specific character format
  Rformatted <- formatC(R, format = 'f', digits = digits, decimal.mark = decimal.mark)

  # Remove leading zeros before the decimal point if lead.decimal is FALSE
  if (!lead.decimal) {
    Rformatted <- gsub("^0\\.", ".", Rformatted)
    Rformatted <- gsub("^-0\\.", "-.", Rformatted)
  }

  # If there are any negative numbers, we want to put a space before the positives to align all
  if (sum(!is.na(R) & R < 0) > 0) {
    Rformatted <- ifelse(!is.na(R) & R > 0, paste0(" ", Rformatted), Rformatted)
  }

  # Add significance levels if desired
  if (show_significance) {
    stars <- ifelse(is.na(p), "",
                    ifelse(p < .001, "***",
                           ifelse(p < .01, "**",
                                  ifelse(p < .05, "*",
                                         ifelse(p < .10, "\u00A0", "")))))
    Rformatted <- paste0(Rformatted, stars)
  }

  # Create a matrix from the formatted correlations
  Rnew <- matrix(Rformatted, nrow = nrow(R), ncol = ncol(R))

    # Set row and column names
  rownames(Rnew) <- colnames(Rnew) <- names(var_list)

  # Replace undesired values based on the triangle parameter
  if (triangle == 'upper') {
    Rnew[lower.tri(Rnew, diag = replace_diagonal)] <- replacement
  } else if (triangle == 'both') {
    Rnew[upper.tri(Rnew, diag = replace_diagonal)] <- replacement
  } else if (replace_diagonal) {
    diag(Rnew) <- replacement
  }

  # Convert NA values to blank cells for display
  Rnew[is.na(Rnew)] <- ""

  # Calculate mean, SD, and Cronbach's alpha if requested
  if (alpha) {
    alpha_vals <- sapply(var_list, function(cols) {
      selected_columns <- data[, cols, drop = FALSE]
      if (is.data.frame(selected_columns) && ncol(selected_columns) > 1) {  # Check if more than one item
        alpha_val <- psych::alpha(selected_columns)$total$std.alpha
      } else {
        alpha_val <- NA
      }
      return(alpha_val)
    })
    formatted_alpha_vals <- formatC(alpha_vals, format = 'f', digits = digits, decimal.mark = decimal.mark)
    formatted_alpha_vals <- gsub("^0\\.", ".", formatted_alpha_vals)  # Remove leading zero
    Rnew <- cbind(`Cronbach's alpha` = formatted_alpha_vals, Rnew)
  }
  if (sd) {
    sds <- apply(x, 2, sd, na.rm = TRUE)
    Rnew <- cbind(SD = formatC(sds, format = 'f', digits = digits, decimal.mark = decimal.mark), Rnew)
  }
  if (mean) {
    means <- colMeans(x, na.rm = TRUE)
    Rnew <- cbind(`Mean` = formatC(means, format = 'f', digits = digits, decimal.mark = decimal.mark), Rnew)
  }

  # Add variable labels if provided
  if (!is.null(var_labels)) {
    colnames(Rnew) <- c(if(mean) "Mean", if(sd) "SD", if(alpha) "Cronbach's alpha", var_labels)
    rownames(Rnew) <- var_labels
  }


  # Preserve row names if using labels
  if (!is.null(var_labels)) {
    rownames(Rnew) <- var_labels
  } else {
    rownames(Rnew) <- names(var_list)
  }

  return(Rnew)
}
