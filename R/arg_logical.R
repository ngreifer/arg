#' Check Logical Argument
#'
#' @description
#' Checks whether an argument is a logical vector (`arg_logical()`) or a logical scalar (`arg_flag()`), i.e., a single logical value. Logical values include `TRUE` and `FALSE`.
#'
#' @inheritParams arg_is
#'
#' @details
#' `NA` values in `arg_flag()` will cause an error to be thrown.
#'
#' @inherit arg_is return
#'
#' @seealso [is.logical()], [rlang::is_bool()]
#'
#' @examples
#' obj <- TRUE
#'
#' try(arg_flag(obj))    # No error
#' try(arg_logical(obj)) # No error
#'
#' obj <- c(TRUE, FALSE)
#'
#' try(arg_flag(obj))    # Error: must be a scalar
#' try(arg_logical(obj)) # No error
#'
#' obj <- 1L
#'
#' try(arg_flag(obj))    # Error must be logical
#' try(arg_logical(obj)) # Error must be logical

#' @export
arg_logical <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.logical(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a logical vector")
  }
}

#' @export
#' @rdname arg_logical
arg_flag <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.logical(x) || !anyNA(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a logical value ({.or {.val {c(TRUE, FALSE)}}})")
  }
  else if (length(x) != 1L) {
    err(.msg %or% "{.arg {(.arg)}} must be a single logical value ({.or {.val {c(TRUE, FALSE)}}})")
  }
}
