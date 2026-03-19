#' Check Equal Arguments
#'
#' Checks whether two arguments are equal (`arg_equal()`) or not equal (`arg_not_equal()`).
#'
#' @inheritParams arg_is
#' @param x,x2 the objects to compare with each other.
#' @param .arg,.arg2 the names of the objects being compared; used in the error message if triggered. Ignored if `.msg` is supplied.
#' @param \dots other arguments passed to [all.equal()].
#'
#' @details
#' Tests for equality are performed by evaluating whether `isTRUE(all.equal(x, x2, ...))` is `TRUE` or `FALSE`.
#'
#' @inherit arg_is return
#'
#' @seealso [all.equal()]
#'
#' @examples
#' f <- function(x, y, ...) {
#'   arg_equal(x, y, ...)
#' }
#'
#' try(f(x = 1, y = 1))      ## No error
#' try(f(x = 1L, y = 1.0))   ## No error despite type difference
#' try(f(x = 1, y = 1.00001, ## No error, within tolerance
#'       tolerance = .001))
#'
#' try(f(x = 1, y = 2))       ## Error: different
#' try(f(x = 1, y = 1.00001)) ## Error
#'
#' g <- function(x, y, ...) {
#'   arg_not_equal(x, y, ...)
#' }
#'
#' try(g(x = 1, y = 1)) ## Error
#' try(g(x = 1, y = 2)) ## No error

#' @export
arg_equal <- function(x, x2, ...,
                      .arg = rlang::caller_arg(x),
                      .arg2 = rlang::caller_arg(x2),
                      .msg = NULL) {
  arg_supplied(x2)

  if (!isTRUE(all.equal(x, x2, ...))) {
    err(.msg %or% "{.arg {(.arg)}} must be equal to {.arg {(.arg2)}}")
  }
}

#' @export
#' @rdname arg_equal
arg_not_equal <- function(x, x2, ...,
                          .arg = rlang::caller_arg(x),
                          .arg2 = rlang::caller_arg(x2),
                          .msg = NULL) {
  arg_supplied(x2)

  if (isTRUE(all.equal(x, x2, ...))) {
    err(.msg %or% "{.arg {(.arg)}} must not be equal to {.arg {(.arg2)}}")
  }
}
