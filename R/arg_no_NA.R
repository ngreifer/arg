#' Check NA in Argument
#'
#' Checks whether an argument does not contain any `NA` values (`arg_no_NA()`), contains only `NA` values (`arg_all_NA()`), or is a scalar `NA` (`arg_is_NA()`).
#'
#' @inheritParams arg_is
#'
#' @details
#' `arg_no_NA()` throws an error when `anyNA(x)` is `0`. `arg_all_NA()` throws an error when `all(is.na(x))` is not `FALSE`. `arg_is_NA()` throws an error when `length(x)` is not 1 or `anyNA(x)` is `FALSE`.
#'
#' `arg_no_NA()` is useful for checking that a meaningful argument was supplied. `arg_all_NA()` and `arg_is_NA()` are primarily used for in [arg_or()] to denote that `NA` is an allowed argument.
#'
#' @inherit arg_is return
#'
#' @seealso [arg_non_null()], [arg_supplied()], [anyNA()]
#'
#' @examples
#' f <- function(x) {
#'   arg_no_NA(x)  ## x must not be NA
#' }
#'
#' try(f(1))           ## No error
#' try(f(NA))          ## Error: x is NA
#' try(f(c(1, NA, 3))) ## Error: x contains NA
#'
#' f2 <- function(y) {
#'   arg_all_NA(y) ## y must be NA
#' }
#'
#' try(f2(NA))          ## No error
#' try(f2(c(NA, NA)))   ## No error
#' try(f2(1))           ## Error: y is not NA
#' try(f2(c(1, NA, 3))) ## Error: y is not all NA

#' @export
arg_no_NA <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (anyNA(x)) {
    if (length(x) == 1L) {
      err(.msg %or% "{.arg {(.arg)}} must not be {.val {NA}}")
    }

    err(.msg %or% "{.arg {(.arg)}} must not contain {.val {NA}} values")
  }
}

#' @export
#' @rdname arg_no_NA
arg_is_NA <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (length(x) != 1L || !is.atomic(x) || !anyNA(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be {.val {NA}}")
  }
}

#' @export
#' @rdname arg_no_NA
arg_all_NA <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!all(is.na(x))) {
    if (length(x) == 1L) {
      err(.msg %or% "{.arg {(.arg)}} must be {.val {NA}}")
    }

    err(.msg %or% "{.arg {(.arg)}} must only contain {.val {NA}} values")
  }
}
