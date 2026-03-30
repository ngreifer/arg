#' Check Supplied Dots Argument
#'
#' Checks whether an argument was supplied to `...`.
#'
#' @inheritParams arg_is
#' @param \dots the `...` argument passed from a calling function. The argument is not evaluated. See Examples.
#'
#' @details
#' `arg_dots_supplied()` checks whether arguments were passed to the `...` (i.e., "dots") argument of a function. These arguments are not evaluated. `arg_dots_supplied()` throws an error if [...length()] is 0. It can be useful for when a function must have additional arguments. For example, [arg_or()] and [when_supplied()] use [arg_dots_supplied()].
#'
#' `arg_dots_not_supplied()` checks whether no arguments were passed to `...`, again without evaluating the arguments and using `...length()`. It can be useful when a function appears to allow further arguments (e.g., because it is a method of a generic), but when the author does not want the user to supply them.
#'
#' @inherit arg_is return
#'
#' @seealso [arg_supplied()]
#'
#' @examples
#' f <- function(...) {
#'   arg_dots_supplied(...)
#' }
#'
#' try(f(1)) # No error: argument supplied
#' try(f())  # Error!

#' @export
arg_dots_supplied <- function(..., .msg = NULL, .call) {
  if (...length() == 0L) {
    err(.msg %or% "an argument must be supplied to {.arg ...}",
        .call = .call)
  }
}

#' @export
#' @rdname arg_dots_supplied
arg_dots_not_supplied <- function(..., .msg = NULL, .call) {
  if (...length() != 0L) {
    err(.msg %or% "no arguments may be supplied to {.arg ...}",
        .call = .call)
  }
}
