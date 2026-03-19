#' Check NULL Argument
#'
#' Checks whether an argument is non-`NULL` (`arg_non_null()`) or is `NULL` (`arg_null()`). `arg_non_null()` throws an error when `length(x)` is `0`. `arg_null()` throws an error when `length(x)` is not `0`.
#'
#' @inheritParams arg_is
#'
#' @details
#' Here, `NULL` refers to any length-0 object, including `NULL`, `logical(0L)`, `list()`, `3[FALSE]`, etc. `arg_non_null()` is useful for checking that a meaningful argument was supplied. `arg_null()` is primarily used for in [arg_or()] to denote that `NULL` is an allowed argument.
#'
#' @inherit arg_is return
#'
#' @seealso [arg_length()], [arg_no_NA()], [arg_supplied()]
#'
#' @examples
#' f <- function(x = NULL, y = NULL) {
#'   arg_non_null(x) ## x must not be NULL
#'   arg_null(y)     ## y must be NULL
#' }
#'
#' try(f(x = 1,    y = NULL)) ## No error
#' try(f(x = NULL, y = NULL)) ## Error: x is NULL
#' try(f(x = 1,    y = 1))    ## Error: y is non-NULL
#'
#' # Any object of length 0 is considered NULL
#' try(f(x = numeric())) ## Error: x is NULL
#' try(f(x = list()))    ## Error: x is NULL
#'
#' test <- c(1, 2)[c(FALSE, FALSE)]
#' try(f(x = test))      ## Error: x is NULL
#'
#' # arg_null() is best used in and_or():
#' f2 <- function(z) {
#'   arg_or(z,
#'          arg_null(),
#'          arg_number())
#' }
#'
#' try(f2(NULL)) ## No error; z can be NULL
#' try(f2(1))    ## No error; z can be a number
#' try(f2(TRUE)) ## Error: z must be NULL or a number

#' @export
arg_non_null <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (is_null(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be non-{.val {list(NULL)}}")
  }
}

#' @export
#' @rdname arg_non_null
arg_null <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (is_not_null(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be {.val {list(NULL)}}")
  }
}
