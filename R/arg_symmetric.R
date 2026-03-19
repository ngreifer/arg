#' Check Symmetric Matrix Argument
#'
#' `arg_symmetric()` checks whether an argument is a square, symmetric, numeric matrix. `arg_cov()` checks whether an argument is like a covariance matrix (i.e., square and symmetric with non-negative diagonal entries). `arg_cor()` checks whether an argument is like a correlation matrix (i.e., square and symmetric with all values between -1 and 1 and ones on the diagonal). `arg_distance()` checks whether an argument is like a distance matrix (i.e., square and symmetric with non-negative entries and zeros on the diagonal).
#'
#' @inheritParams arg_is
#' @param tol `numeric`; the tolerance value used to assess symmetry and any numerical bounds. Passed to [isSymmetric()].
#' @param \dots other arguments passed to [isSymmetric()] (and eventually to [all.equal()]).
#'
#' @details
#' These functions check that an argument is a square, symmetric, numeric matrix. This can be useful when a function can accept a covariance matrix, correlation matrix, or distance matrix. `arg_cov()` will throw an error if any values on its diagonal are less than `-tol`. `arg_cor()` will throw an error if any of its values are greater than `1 + tol` in absolute value or if the diagonal entries are not between `-1 - tol` and `1 + tol`. `arg_distance()` will thrown an error if any of its values are less than `-tol` or if the diagonal entries are not between `-tol` and `tol`. The tolerance is just slightly greater than 0 to allow for numeric imprecision.
#'
#' No checks on semi-definiteness or rank are performed.
#'
#' @inherit arg_is return
#'
#' @seealso [arg_numeric()], [arg_matrix()], [arg_between()], [isSymmetric()]
#'
#' @examples
#' set.seed(1234)
#' mat <- matrix(rnorm(12), ncol = 3L) # Non square
#' sym_mat <- -crossprod(mat)          # Square, symmetric
#' cov_mat <- cov(mat)                 # Covariance
#' cor_mat <- cor(mat)                 # Correlation
#' dist_mat <- as.matrix(dist(mat))    # Distance
#'
#' try(arg_symmetric(mat))     # Error: not square
#' try(arg_symmetric(sym_mat)) # No error
#'
#' try(arg_cov(sym_mat)) # Error: diagonal must be non-negative
#' try(arg_cov(cov_mat)) # No error
#'
#' try(arg_cor(cov_mat)) # Error: values must be in [-1, 1]
#' try(arg_cor(cor_mat)) # No error
#'
#' try(arg_distance(cor_mat))  # Error: diagonal must be 0
#' try(arg_distance(dist_mat)) # No error

#' @export
arg_symmetric <- function(x, tol = 100 * .Machine$double.eps, ...,
                          .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.matrix(x) || nrow(x) != ncol(x) || !is.numeric(x) ||
      !isSymmetric(unname(x), tol = tol, ...)) {
    if (is_not_null(.msg)) {
      err(.msg)
    }

    if (isTRUE(all.equal(tol, Inf))) {
      err("{.arg {(.arg)}} must be a square, numeric matrix")
    }

    err("{.arg {(.arg)}} must be a square, symmetric, numeric matrix")
  }
}

#' @export
#' @rdname arg_symmetric
arg_cov <- function(x, tol = 100 * .Machine$double.eps, ...,
                    .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.matrix(x) || nrow(x) != ncol(x) || !is.numeric(x) ||
      !isSymmetric(unname(x), tol = tol, ...)) {
    err(.msg %or% "{.arg {(.arg)}} must be a square, symmetric, numeric matrix")
  }

  if (any(diag(x) < -tol)) {
    err(.msg %or% "{.arg {(.arg)}} must be a square, symmetric matrix with non-negative values on the diagonal")
  }
}

#' @export
#' @rdname arg_symmetric
arg_cor <- function(x, tol = 100 * .Machine$double.eps, ...,
                    .arg = rlang::caller_arg(x), .msg = NULL) {

  if (!is.matrix(x) || nrow(x) != ncol(x) || !is.numeric(x) ||
      !isSymmetric(unname(x), tol = tol, ...)) {
    err(.msg %or% "{.arg {(.arg)}} must be a square, symmetric, numeric matrix")
  }

  if (any(abs(x) > 1 + tol)) {
    err(.msg %or% "all values in {.arg {(.arg)}} must be between {.val {c(-1, 1)}}")
  }

  if (any(abs(diag(x) - 1) > tol)) {
    err(.msg %or% "{.arg {(.arg)}} must be a square, symmetric matrix with ones on the diagonal")
  }
}

#' @export
#' @rdname arg_symmetric
arg_distance <- function(x, tol = 100 * .Machine$double.eps, ...,
                         .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.matrix(x) || nrow(x) != ncol(x) || !is.numeric(x) ||
      !isSymmetric(unname(x), tol = tol, ...)) {
    err(.msg %or% "{.arg {(.arg)}} must be a square, symmetric, numeric matrix")
  }

  if (any(abs(diag(x)) > tol)) {
    err(.msg %or% "{.arg {(.arg)}} must be a square, symmetric matrix with zeros on the diagonal")
  }

  if (any(x < -tol)) {
    err(.msg %or% "all values in {.arg {(.arg)}} must be non-negative")
  }
}
