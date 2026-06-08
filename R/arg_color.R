#' Check Color Argument
#'
#' @description
#' Checks whether an argument is a valid color. `arg_color()` additionally requires that a single color is supplied. British spellings are supported.
#'
#' @inheritParams arg_is
#'
#' @details
#' A color specification is considered valid if [grDevices::col2rgb()] returns a matrix when applied to it.
#'
#' @inherit arg_is return
#'
#' @seealso [grDevices::col2rgb()]
#'
#' @examples
#' f <- function(z) {
#'   arg_colors(z)
#' }
#'
#' try(f("red"))       # No error
#' try(f("redhehehe")) # Error: not a valid color name
#'
#' try(f("#A4A473")) # No error
#' try(f("~A4A473")) # Error: not a valid hex code
#'
#' try(f(15))  # No error
#' try(f(-15)) # Error: not a valid color number
#'
#' try(f(list("red", 15)))  # No error
#' try(f(list("red", -15))) # Error

#' @export
arg_color <- function(x, .arg = rlang::caller_arg(x), .msg = NULL, .call) {
  if (!is_scalar(x) || !is_color(x)) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    err("{.arg {(.arg)}} must be a valid color",
        .call = .call)
  }
}

#' @export
#' @rdname arg_color
arg_colors <- function(x, .arg = rlang::caller_arg(x), .msg = NULL, .call) {
  if (!all_apply(x, is_color)) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    err("each element of {.arg {(.arg)}} must be a valid color",
        .call = .call)
  }
}

#' @export
#' @rdname arg_color
arg_colour <- function(x, .arg = rlang::caller_arg(x), .msg = NULL, .call) {
  if (!is_scalar(x) || !is_color(x)) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    err("{.arg {(.arg)}} must be a valid colour",
        .call = .call)
  }
}

#' @export
#' @rdname arg_color
arg_colours <- function(x, .arg = rlang::caller_arg(x), .msg = NULL, .call) {
  if (!all_apply(x, is_color)) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    err("each element of {.arg {(.arg)}} must be a valid colour",
        .call = .call)
  }
}
