#' Check Function Argument
#'
#' @description
#' Checks whether an argument is a function.
#'
#' @inheritParams arg_is
#'
#' @inherit arg_is return
#'
#' @seealso [rlang::is_function()], [arg_is()]
#'
#' @examples
#' f <- function(z) {
#'   arg_function(z)
#' }
#'
#' try(f(print))   # No error
#' try(f("print")) # Error: must be a function

#' @export
arg_function <- function(x, .arg = rlang::caller_arg(x), .msg = NULL, .call) {
  if (!rlang::is_function(x)) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call)
    }

    err("{.arg {(.arg)}} must be a function",
        .call = .call)
  }
}
