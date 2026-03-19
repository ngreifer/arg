#' Check Index Argument
#'
#' @description
#' Checks whether an argument is a valid column index (`arg_index()`) of a data set or a vector thereof (`arg_indices()`).
#'
#' @inheritParams arg_is
#' @param data a data set (i.e., a matrix or data frame)
#' @param .arg_data the name of the argument supplied to `data` to appear in error messages. The default is to extract the argument's name using [rlang::caller_arg()]. Ignored if `.msg` is supplied.
#'
#' @details
#' For `arg_indices()`, an error will be thrown unless one of the following are true:
#'
#' * `x` is a vector of counts (see [arg_counts()]) less than or equal to `ncol(data)`
#' * `x` is a character vector with values a subset of `colnames(data)`
#'
#' For `arg_index()`, `x` additionally must have length equal to 1. Passing `arg_index()` ensures that `data[, x]` (if `data` is a matrix) or `data[[x]]` (if `x` is a data frame) evaluate correctly.
#'
#' If `data` has no column names, an error will be thrown if `x` is a character vector.
#'
#' @inherit arg_is return
#'
#' @seealso [arg_counts()], [arg_character()]
#'
#' @examples
#' dat <- data.frame(col1 = 1:5,
#'                   col2 = 6:10)
#'
#' f <- function(z) {
#'   arg_index(z, dat)
#' }
#'
#' try(f(1))         # No error
#' try(f(3))         # Error: not a valid index
#' try(f("col1"))    # No error
#' try(f("bad_col")) # Error: not a valid index
#' try(f(1:2))       # Error: arg_index() requires scalar
#'
#' mat <- matrix(1:9, ncol = 3)
#'
#' g <- function(z) {
#'   arg_indices(z, mat)
#' }
#'
#' try(g(1))     # No error
#' try(g(1:3))   # No error
#' try(g("col")) # Error: `mat` has no names

#' @export
arg_index <- function(x, data,
                      .arg = rlang::caller_arg(x),
                      .arg_data = rlang::caller_arg(data),
                      .msg = NULL) {
  arg_supplied(data)
  arg_data(data)

  if (is_null(colnames(data))) {
    if (length(x) != 1L ||
        (((!is.integer(x) && (!is.numeric(x) || !all(check_if_zero(x - trunc(x)))))
          || any(x < 1) || any(x > ncol(data))))) {
      err(.msg %or% "{.arg {(.arg)}} must be the index of a column in {.arg {(.arg_data)}}")
    }
  }
  else if (length(x) != 1L ||
           (((!is.integer(x) && (!is.numeric(x) || !all(check_if_zero(x - trunc(x)))))
             || any(x < 1) || any(x > ncol(data))) &&
            (!is.character(x) || !all(x %in% colnames(data))))) {
    err(.msg %or% "{.arg {(.arg)}} must be the name or index of a column in {.arg {(.arg_data)}}")
  }
}

#' @export
#' @rdname arg_index
arg_indices <- function(x, data,
                        .arg = rlang::caller_arg(x),
                        .arg_data = rlang::caller_arg(data),
                        .msg = NULL) {
  arg_supplied(data)
  arg_data(data)

  if (is_null(colnames(data))) {
    if (is_null(x) ||
        (((!is.integer(x) && (!is.numeric(x) || !all(check_if_zero(x - trunc(x)))))
          || any(x < 1) || any(x > ncol(data))))) {
      err(.msg %or% "{.arg {(.arg)}} must be the {cli::qty(length(x))} ind{?ex/ices} of {?a/} column{?s} in {.arg {(.arg_data)}}")
    }
  }
  else if (is_null(x) ||
           (((!is.integer(x) && (!is.numeric(x) || !all(check_if_zero(x - trunc(x)))))
             || any(x < 1) || any(x > ncol(data))) &&
            (!is.character(x) || !all(x %in% colnames(data))))) {
    err(.msg %or% "{.arg {(.arg)}} must be the {cli::qty(length(x))} name{?s} or ind{?ex/ices} of {?a/} column{?s} in {.arg {(.arg_data)}}")
  }
}
