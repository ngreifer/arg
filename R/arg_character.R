#' Check Character Argument
#'
#' @description
#' Checks whether an argument is a character vector (`arg_character()`), a character scalar (`arg_string()`), or a factor (`arg_factor()`).
#'
#' @inheritParams arg_is
#'
#' @details
#' `NA` values in `arg_string()` will cause an error to be thrown.
#'
#' @inherit arg_is return
#'
#' @seealso [is.character()], [is.factor()], [rlang::is_string()]
#'
#' @examples
#' f <- function(z) {
#'   arg_string(z)
#' }
#'
#' try(f("a")) # No error
#' try(f(c("a", "b"))) # Error: arg_string() requires scalar
#' try(f(NA)) # NAs not allowed for arg_string()

#' @export
arg_character <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                          .call) {
  if (!is.character(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a character vector",
        .call = .call)
  }
}

#' @export
#' @rdname arg_character
arg_string <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                       .call) {
  if (length(x) != 1L || !is.character(x) || anyNA(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a string",
        .call = .call)
  }
}

#' @export
#' @rdname arg_character
arg_factor <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                       .call) {
  if (!is.factor(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a factor",
        .call = .call)
  }
}
