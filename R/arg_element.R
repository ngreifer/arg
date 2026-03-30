#' Check Element
#'
#' Checks whether values in an argument are all elements of some set (`arg_element()`) or are not all elements of a set (`arg_not_element()`). `arg_element()` throws an error when `all(is.element(x, values))` is `FALSE`, and `arg_not_element()` throws an error when `any(is.element(x, values))` is `TRUE`.
#'
#' @inheritParams arg_is
#' @param values the values to check `x` against.
#'
#' @details
#' `arg_element()` can be useful for checking whether an argument matches one or more allowed values. It's important that a check is done beforehand to ensure `x` is the correct type, e.g., using [arg_string()] or [arg_character()] if `values` is a character vector. No partial matching is used; the values must match exactly. Use [match_arg()] to allow partial matching and return the full version of the supplied argument.
#'
#' `arg_not_element()` can be useful for ensuring there is no duplication of values between an argument and some other set.
#'
#' @inherit arg_is return
#'
#' @seealso [is.element()], [match_arg()]
#'
#' @examples
#' f <- function(z) {
#'   arg_element(z, c("opt1", "opt2", "opt3"))
#' }
#'
#' try(f("opt1"))            # No error
#' try(f(c("opt1", "opt2"))) # No error, all are elements
#' try(f(c("opt1", "opt1"))) # No error: repeats allowed
#' try(f("bad_arg"))         # Error: not an element of set
#' try(f("opt"))             # Error: partial matching not allowed
#' try(f(c("opt1", "bad_arg"))) # Error: one non-match
#'
#' g <- function(z) {
#'   arg_not_element(z, c("bad1", "bad2", "bad3"))
#' }
#'
#' try(g("bad1"))            # Error: z is an element
#' try(g(c("bad1", "opt2"))) # Error: at least one bad match
#' try(g("opt1"))            # No error: not an element
#' try(g(c("opt1", "opt2"))) # No error, none are elements

#' @export
arg_element <- function(x, values,
                        .arg = rlang::caller_arg(x), .msg = NULL,
                        .call) {
  arg_supplied(values, .call = rlang::current_env())

  if (is_null(x) || !all(is.element(x, values))) {
    if (is_not_null(.msg)) {
      err(.msg, .call = .call)
    }

    if (is_null(values)) {
      err("{.arg {(.arg)}} cannot take on any value",
          .call = .call)
    }

    one_of <- if (length(values) > 1L) "one of"

    if (length(x) <= 1L) {
      err("{.arg {(.arg)}} must be {one_of} {.or {.val {values}}}",
          .call = .call)
    }

    err("each element of {.arg {(.arg)}} must be {one_of} {.or {.val {values}}}",
        .call = .call)
  }
}

#' @export
#' @rdname arg_element
arg_not_element <- function(x, values,
                            .arg = rlang::caller_arg(x), .msg = NULL,
                            .call) {
  arg_supplied(values, .call = rlang::current_env())

  if (is_not_null(x) && any(is.element(x, values))) {
    if (is_not_null(.msg)) {
      err(.msg, .call = .call)
    }

    one_of <- if (length(values) > 1L) "one of"

    if (length(x) == 1L) {
      err("{.arg {(.arg)}} must not be {one_of} {.or {.val {values}}}",
          .call = .call)
    }

    err("no element of {.arg {(.arg)}} may be {one_of} {.or {.val {values}}}",
        .call = .call)
  }
}
