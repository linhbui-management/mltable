#' Calculate p-values for a correlation matrix
#'
#' This function calculates p-values for a correlation matrix using `cor.test()`.
#'
#' @param R A correlation matrix.
#' @param x The original data matrix.
#' @param method The correlation method to use (e.g., "pearson", "spearman").
#' @param use How to handle missing values (e.g., "pairwise.complete.obs").
#' @importFrom stats cor.test
#' @return A matrix of p-values corresponding to the correlation matrix.
#'
#' @examples
#' \dontrun{
#' x <- matrix(rnorm(100), ncol = 5)
#' R <- cor(x, method = "pearson", use = "pairwise.complete.obs")
#' p_values <- calculate_p_values(R, x, method = "pearson", use = "pairwise.complete.obs")
#' print(p_values)
#' }
#'
#' @export
calculate_p_values <- function(R, x, method, use) {
  n <- nrow(x)
  p <- matrix(NA, ncol = ncol(R), nrow = nrow(R))
  for (i in 1:(ncol(R)-1)) {
    for (j in (i+1):ncol(R)) {
      test <- cor.test(x[, i], x[, j], method = method, use = use)
      p[i, j] <- test$p.value
      p[j, i] <- test$p.value
    }
  }
  return(p)
}
