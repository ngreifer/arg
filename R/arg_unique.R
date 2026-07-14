#' Check Unique Argument
#'
#' @description
#' Checks whether an argument contains only unique (i.e., distinct) values.
#'
#' @inheritParams arg_is
#' @param \dots further arguments passed to [anyDuplicated()], which performs the checking.
#'
#' @inherit arg_is return
#'
#' @seealso [anyDuplicated()]
#'
#' @examples
#' f <- function(z) {
#'   arg_unique(z)
#' }
#'
#' try(f(1:3))     # No error
#' try(f(NULL))    # No error for NULL
#' try(f(c(1, 1))) # Error: repeated values

#' @export
arg_unique <- function(x, ..., .arg = rlang::caller_arg(x), .msg = NULL,
                       .call) {
  if (is_not_null(x) && anyDuplicated(x, ...) != 0) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    err("{.arg {(.arg)}} must only contain unique values",
        .call = .call)
  }
}
