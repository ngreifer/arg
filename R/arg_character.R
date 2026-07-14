#' Check Character Argument
#'
#' @description
#' Checks whether an argument is a character vector (`arg_character()`), a character scalar (`arg_string()`), a factor (`arg_factor()`), or an ordered factor (`arg_ordered()`).
#'
#' @inheritParams arg_is
#'
#' @details
#' `NA` values in `arg_string()` will cause an error to be thrown.
#'
#' @inherit arg_is return
#'
#' @seealso [is.character()], [is.factor()], [is.ordered()], [rlang::is_string()]
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

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    err("{.arg {(.arg)}} must be a character vector",
        .call = .call)
  }
}

#' @export
#' @rdname arg_character
arg_string <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                       .call) {
  if (!is_scalar(x) || !is.character(x) || anyNA(x)) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    if (is_scalar(x) && is.character(x)) {
      err("{.arg {(.arg)}} must not be {.val {NA}}",
          .call = .call)
    }

    err("{.arg {(.arg)}} must be a string",
        .call = .call)
  }
}

#' @export
#' @rdname arg_character
arg_factor <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                       .call) {
  if (!is.factor(x)) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    err("{.arg {(.arg)}} must be a factor",
        .call = .call)
  }
}

#' @export
#' @rdname arg_character
arg_ordered <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                       .call) {
  if (!is.ordered(x)) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    err("{.arg {(.arg)}} must be an ordered factor",
        .call = .call)
  }
}
