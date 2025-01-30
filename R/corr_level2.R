#' Calculate and Format Correlation Matrix for Level 2 Data
#'
#' This function calculates the correlation matrix for a given list of Level 2
#' variables using the aggregated variables (e.g., group level). The function
#' formats the results, and includes additional metrics such as mean, standard deviation,
#' Cronbach's alpha, and mean or median rwg.j if requested.
#'
#' @param data A data frame containing the variables specified in `var_list`.
#' @param var_list A named list of variables where each entry is either a vector of
#' column indices or column names from the `data` data frame.
#' @param groupid The column name in `data` that indicates group membership.
#' @param type The type of correlation to compute. Options are
#' "pearson" (default), "spearman", or "kendall".
#' @param digits Integer indicating the number of decimal places to be used for
#' formatting the correlation values. Default is 3.
#' @param decimal.mark Character to be used as the decimal mark. Default is ".".
#' @param triangle A character string indicating which part of the correlation
#' matrix to display. Options are "both", "upper", or "lower" (default is "lower").
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
#' before the decimal point. Default is TRUE.
#' @param var_labels An optional vector of variable labels to use in the output.
#' Default is NULL.
#' @param mean Logical indicating whether to include the mean of
#' the aggregated variables at Level 2 (e.g., group level).
#' Default is TRUE.
#' @param sd Logical indicating whether to include the standard deviation of
#' the aggregated variables at Level 2 (e.g., group level). Default is TRUE.
#' @param alpha Logical indicating whether to include Cronbach's alpha for
#' the variables, which is calculated using items at Level 1. Default is TRUE.
#' @param rwg Logical indicating whether to include the mean or median of rwg.j,
#' which is calculated by function multilevel::rwg.j.
#' Default is TRUE.
#' @param rwg_scale The scale for calculating rwg.j, representing the number of
#' response options (e.g., 1 = Strongly Disagree to 5 = Strongly Agree). Default is 5.
#' @param rwg_method The method for calculating rwg.j.
#' Options are "mean" (default) or "median".
#' @return A formatted correlation matrix as a data frame, which can be exported
#' as a CSV file.
#'
#' @examples
#' # Example usage
#' data <- teamstate
#' \dontrun{
#' var_list2 <- list(
#'   var1 = 5:14,
#'   var2 = 15:24,
#'   var3 = 25:28
#' )
#' result <- corr_level2(data = teamstate,
#'                       var_list = var_list2,
#'                       groupid = "Team",
#'                       var_labels = c("Team PA", "Team NA", "Team Psychological Safety"),
#'                       rwg_scale = 7)
#' print(result)
#' }
#'
#' @seealso \code{\link{cor}}, \code{\link{cor.test}}
#'
#' @export

corr_level2 <- function(data,
                        var_list,
                        groupid,
                        type = c("pearson", "spearman", "kendall"),
                        digits = 3,
                        decimal.mark = ".",
                        triangle = c("lower", "both", "upper"),  # Default set to "lower"
                        use = "pairwise.complete.obs",  # Default set to "pairwise.complete.obs"
                        show_significance = TRUE,
                        replace_diagonal = TRUE,
                        replacement = NA,
                        lead.decimal = TRUE,
                        var_labels = NULL,
                        mean = TRUE,
                        sd = TRUE,
                        alpha = TRUE,
                        rwg = TRUE,
                        rwg_scale = 7,
                        rwg_method = c("mean", "median")) {

  # Require and load necessary packages
  require_package <- function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, dependencies = TRUE)
      library(pkg, character.only = TRUE)
    }
  }
  require_package("psych")
  require_package("multilevel")

  # Match arguments
  type <- match.arg(type)
  triangle <- match.arg(triangle)
  use <- match.arg(use, choices = c("all.obs", "complete.obs", "pairwise.complete.obs"))
  rwg_method <- match.arg(rwg_method)

  # Validate arguments
  stopifnot({
    is.numeric(digits) && digits >= 0
    is.logical(show_significance)
    is.logical(replace_diagonal)
    is.logical(lead.decimal)
    is.null(var_labels) || length(var_labels) == length(var_list)
    is.logical(mean)
    is.logical(sd)
    is.logical(alpha)
    is.logical(rwg)
    is.numeric(rwg_scale) && rwg_scale > 0
  })

  # Check if groupid exists in data
  if (!groupid %in% colnames(data)) {
    stop("The specified groupid does not exist in the data.")
  }

  # Extract columns and calculate new variables
  df_new <- data.frame(matrix(nrow = nrow(data), ncol = 0))
  for (new_var in names(var_list)) {
    selected_columns <- data[, var_list[[new_var]], drop = FALSE]
    if (!all(sapply(selected_columns, is.numeric))) {
      stop("All columns used for calculating new variables must be numeric.")
    }
    df_new[[new_var]] <- rowMeans(selected_columns, na.rm = TRUE)
  }

  # Aggregate data by groupid
  df_new$groupid <- as.factor(data[[groupid]])

  # Define a custom function to handle na.rm = TRUE
  mean_na_rm <- function(x) mean(x, na.rm = TRUE)

  # Use aggregate with the custom function
  agg_df <- aggregate(. ~ groupid, data = df_new, FUN = mean_na_rm)

  # Calculate correlation matrix using cor()
  x <- as.matrix(agg_df[, -1])  # Exclude groupid column
  correlation_matrix <- cor(x, method = type, use = use)

  # Calculate p-values using cor.test() for the lower triangle
  p_values <- matrix(NA, nrow = ncol(x), ncol = ncol(x))
  for (i in 1:ncol(x)) {
    for (j in 1:i) {  # Only calculate for the lower triangle
      if (i != j) {
        test_result <- cor.test(x[, i], x[, j], method = type)
        p_values[i, j] <- test_result$p.value
      }
    }
  }

  # Format correlation matrix
  Rformatted <- formatC(correlation_matrix, format = 'f', digits = digits, decimal.mark = decimal.mark)
  if (!lead.decimal) {
    Rformatted <- gsub("^0\\.", ".", Rformatted)
    Rformatted <- gsub("^-0\\.", "-.", Rformatted)
  }
  if (sum(!is.na(correlation_matrix) & correlation_matrix < 0) > 0) {
    Rformatted <- ifelse(!is.na(correlation_matrix) & correlation_matrix > 0, paste0(" ", Rformatted), Rformatted)
  }

  # Add significance levels if requested
  if (show_significance) {
    stars <- ifelse(is.na(p_values), "",
                    ifelse(p_values < .001, "***",
                           ifelse(p_values < .01, "**",
                                  ifelse(p_values < .05, "*",
                                         ifelse(p_values < .10, "†", "")))))
    Rformatted <- paste0(Rformatted, stars)
  }

  # Build final matrix
  Rnew <- matrix(Rformatted, ncol = ncol(x))
  rownames(Rnew) <- colnames(Rnew) <- names(agg_df)[-1]

  # Replace undesired values based on triangle parameter
  if (triangle == 'upper') {
    Rnew[lower.tri(Rnew, diag = replace_diagonal)] <- replacement
  } else if (triangle == 'lower') {
    Rnew[upper.tri(Rnew, diag = replace_diagonal)] <- replacement
  } else if (replace_diagonal) {
    diag(Rnew) <- replacement
  }
  Rnew[is.na(Rnew)] <- ""

  # Calculate additional statistics if requested
  if (rwg) {
    rwg_vals <- sapply(var_list, function(cols) {
      if (length(cols) > 1) {
        rwg_result <- multilevel::rwg.j(as.matrix(data[, cols]), data[[groupid]], ranvar = (rwg_scale^2 - 1) / 12)
        if (rwg_method == "mean") {
          mean(rwg_result$rwg.j, na.rm = TRUE)
        } else {
          median(rwg_result$rwg.j, na.rm = TRUE)
        }
      } else {
        NA
      }
    })
    formatted_rwg_vals <- formatC(rwg_vals, format = 'f', digits = digits, decimal.mark = decimal.mark)
    formatted_rwg_vals <- gsub("^0\\.", ".", formatted_rwg_vals)
    Rnew <- cbind(`Mean rwg.j` = formatted_rwg_vals, Rnew)
  }
  if (alpha) {
    alpha_vals <- sapply(var_list, function(cols) {
      if (length(cols) > 1) {
        psych::alpha(data[, cols])$total$std.alpha
      } else {
        NA
      }
    })
    formatted_alpha_vals <- formatC(alpha_vals, format = 'f', digits = digits, decimal.mark = decimal.mark)
    formatted_alpha_vals <- gsub("^0\\.", ".", formatted_alpha_vals)
    Rnew <- cbind(`Cronbach's Alpha` = formatted_alpha_vals, Rnew)
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
    colnames(Rnew) <- c(if (mean) "Mean", if (sd) "SD", if (alpha) "Cronbach's Alpha", if (rwg) "rwg.j", var_labels)
    rownames(Rnew) <- var_labels
  }

  # Convert matrix to data frame
  Rnew <- as.data.frame(Rnew, stringsAsFactors = FALSE)

  # Preserve row names if using labels
  if (!is.null(var_labels)) {
    rownames(Rnew) <- var_labels
  } else {
    rownames(Rnew) <- names(var_list)
  }
  return(Rnew)
}
