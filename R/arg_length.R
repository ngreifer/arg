#' Check Argument Length
#'
#' @description
#' Checks whether an argument has a specified length.
#'
#' @inheritParams arg_is
#' @param len `integer`; the allowed length(s) of `x`. Default is 1.
#'
#' @details
#' `len` can contain multiple allowed counts; an error will be thrown only if `length(x)` is not equal to any value of `len`.
#'
#' @inherit arg_is return
#'
#' @seealso [length()], [arg_non_null()] to specifically test that an object's length is or is not 0.
#'
#' @examples
#' obj <- 1:4
#'
#' try(arg_length(obj, 1))
#' try(arg_length(obj, 4))
#' try(arg_length(obj, c(1, 4)))
#'
#' # These test the same thing:
#' try(arg_length(obj, c(0:3)))
#' try(when_not_null(obj,
#'                   arg_length(1:3)))

#' @export
arg_length <- function(x, len = 1L,
                       .arg = rlang::caller_arg(x), .msg = NULL,
                       .call) {
  arg_counts(len, .call = rlang::current_env())

  if (!length(x) %in% len) {
    err(.msg %or% "{.arg {(.arg)}} must have length {.or {len}}",
        .call = .call)
  }
}
