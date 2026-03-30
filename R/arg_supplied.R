#' Check Supplied Argument
#'
#' Checks whether an argument with no default value was supplied. An error will be thrown if `rlang::is_missing(x)` is `TRUE`, i.e., if an argument with no default is omitted from a function call.
#'
#' @inheritParams arg_is
#'
#' @inherit arg_is return
#'
#' @seealso [arg_non_null()], [arg_no_NA()], [rlang::is_missing()], [rlang::check_required()]
#'
#' @examples
#' f <- function(z) {
#'   arg_supplied(z)
#' }
#'
#' try(f(1)) ## No error: argument supplied
#' try(f())  ## Error!
#'
#' # Will not throw for NULL or default arguments
#' try(f(NULL)) ## No error: argument supplied
#'
#' f2 <- function(z = NULL) {
#'   arg_supplied(z)
#' }
#'
#' try(f2()) ## No error; default provided

#' @export
arg_supplied <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                         .call) {
  if (rlang::is_missing(x)) {
    if (is_not_null(.msg)) {
      err(.msg, .call = .call)
    }

    arg_expr <- substitute(x)

    if (!rlang::is_symbol(arg_expr)) {
      err("{.arg x} must be an argument name",
          .call = rlang::current_env())
    }

    err("an argument to {.arg {(.arg)}} must be supplied",
        .call = .call)
  }
}
