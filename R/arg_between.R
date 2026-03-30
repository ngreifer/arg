#' Check Values in Range
#'
#' Checks whether values are within a range (`arg_between()`), greater than some value (`arg_gt()`), greater than or equal to some value (`arg_gte()`), less than some value (`arg_lt()`), or less than or equal to some value (`arg_lte()`).
#'
#' @inheritParams arg_is
#' @param range a vector of two values identifying the required range.
#' @param inclusive a logical vector identifying whether the range boundaries are inclusive or not. If only one value is supplied, it is applied to both range boundaries. Default is `TRUE`, which will not throw an error if `x` is equal to the boundaries.
#' @param bound the bound to check against. Default is 0.
#'
#' @details
#' `x` is not checked for type, as it is possible for values other than numeric values to be passed and compared; however, an error will be thrown if `typeof(x)` is not equal to `typeof(range)` or `typeof(bound)`. `NA` values of `x` will be removed. The arguments to `range`, `inclusive`, and `bound` are checked for appropriateness.
#'
#' @inherit arg_is return
#'
#' @examples
#' z <- 2
#'
#' try(arg_between(z, c(1, 3))) # No error
#' try(arg_between(z, c(1, 2))) # No error
#' try(arg_between(z, c(1, 2),
#'                 inclusive = FALSE)) # Error
#' try(arg_between(z, c(1, 2),
#'                 inclusive = c(TRUE, FALSE))) # Error
#'
#' try(arg_gt(z, 0))  # No error
#' try(arg_gt(z, 2))  # Error
#' try(arg_gte(z, 2)) # No error
#'
#' try(arg_lt(z, 0))  # Error
#' try(arg_lt(z, 2))  # Error
#' try(arg_lte(z, 2)) # No error
#'
#' try(arg_lte(z, "3")) # Error: wrong type

#' @export
arg_between <- function(x, range = c(0, 1), inclusive = TRUE,
                        .arg = rlang::caller_arg(x), .msg = NULL,
                        .call) {

  arg_length(range, 2L, .call = rlang::current_env())
  arg_logical(inclusive, .call = rlang::current_env())
  arg_length(inclusive, 1:2, .call = rlang::current_env())

  if (length(inclusive) == 1L) {
    inclusive <- inclusive[c(1L, 1L)]
  }

  if (is.unsorted(range)) {
    o_range <- order(range)
    range <- range[o_range]
    inclusive <- inclusive[o_range]
  }

  .gt_comp <- if (inclusive[1L]) function(a, b) {a >= b} else function(a, b) {a > b}
  .lt_comp <- if (inclusive[2L]) function(a, b) {a <= b} else function(a, b) {a < b}

  if (!are_comparable(x, range[1L], .gt_comp) ||
      !are_comparable(x, range[2L], .lt_comp) ||
      !safe_all(.gt_comp(x, range[1L])) ||
      !safe_all(.lt_comp(x, range[2L]))) {

    if (is_not_null(.msg)) {
      err(.msg)
    }

    each_element_of <- if (length(x) > 1L) "each element of"

    if (all(inclusive)) {
      err("{each_element_of} {.arg {(.arg)}} must be between {.val {range}} (inclusive)",
          .call = .call)
    }

    if (!any(inclusive)) {
      err("{each_element_of} {.arg {(.arg)}} must be between {.val {range}} (exclusive)",
          .call = .call)
    }

    .gt_str <- {
      if (range[1L] == 0 && !inclusive[1L]) "positive"
      else if (inclusive[1L]) "greater than or equal to {.val {range[1L]}}"
      else "greater than {.val {range[1L]}}"
    }

    .lt_str <- {
      if (range[2L] == 0 && !inclusive[2L]) "negative"
      else if (inclusive[2L]) "less than or equal to {.val {range[2L]}}"
      else "less than {.val {range[2L]}}"
    }

    err(sprintf("{each_element_of} {.arg {(.arg)}} must be %s and %s",
                .gt_str, .lt_str),
        .call = .call)
  }
}

#' @export
#' @rdname arg_between
arg_gt <- function(x, bound = 0,
                   .arg = rlang::caller_arg(x), .msg = NULL,
                   .call) {
  arg_length(bound, 1L, .call = rlang::current_env())

  if (!are_comparable(x, bound, `>`) ||
      !safe_all(x > bound)) {

    if (is_not_null(.msg)) {
      err(.msg, .call = .call)
    }

    each_element_of <- if (length(x) > 1L) "each element of"

    if (bound == 0) {
      err("{each_element_of} {.arg {(.arg)}} must be positive",
          .call = .call)
    }

    err("{each_element_of} {.arg {(.arg)}} must be greater than {.val {bound}}",
        .call = .call)
  }
}

#' @export
#' @rdname arg_between
arg_gte <- function(x, bound = 0,
                    .arg = rlang::caller_arg(x), .msg = NULL,
                    .call) {
  arg_length(bound, 1L, .call = rlang::current_env())

  if (!are_comparable(x, bound, `>=`) ||
      !safe_all(x >= bound)) {

    if (is_not_null(.msg)) {
      err(.msg, .call = .call)
    }

    each_element_of <- if (length(x) > 1L) "each element of"

    # if (bound == 0) {
    #   err(.msg %or% "{each_element_of} {.arg {(.arg)}} must be non-negative",
    #       .call = .call)
    # }

    err("{each_element_of} {.arg {(.arg)}} must be greater than or equal to {.val {bound}}",
        .call = .call)
  }
}

#' @export
#' @rdname arg_between
arg_lt <- function(x, bound = 0,
                   .arg = rlang::caller_arg(x), .msg = NULL,
                   .call) {
  arg_length(bound, 1L, .call = rlang::current_env())

  if (!are_comparable(x, bound, `<`) ||
      !safe_all(x < bound)) {

    if (is_not_null(.msg)) {
      err(.msg, .call = .call)
    }

    each_element_of <- if (length(x) > 1L) "each element of"

    if (bound == 0) {
      err("{each_element_of} {.arg {(.arg)}} must be negative",
          .call = .call)
    }

    err("{each_element_of} {.arg {(.arg)}} must be less than {.val {bound}}",
        .call = .call)
  }
}

#' @export
#' @rdname arg_between
arg_lte <- function(x, bound = 0,
                    .arg = rlang::caller_arg(x), .msg = NULL,
                    .call) {
  arg_length(bound, 1L, .call = rlang::current_env())

  if (!are_comparable(x, bound, `<=`) ||
      !safe_all(x <= bound)) {

    if (is_not_null(.msg)) {
      err(.msg, .call = .call)
    }

    each_element_of <- if (length(x) > 1L) "each element of"

    # if (bound == 0) {
    #   err("{each_element_of} {.arg {(.arg)}} must be non-positive",
    #       .call = .call)
    # }

    err("{each_element_of} {.arg {(.arg)}} must be less than or equal to {.val {bound}}",
        .call = .call)
  }
}

are_comparable <- function(x, y, comparison) {
  if (is.numeric(x)) {
    return(is.numeric(y))
  }

  if (is.numeric(y)) {
    return(is.numeric(x))
  }

  if (is.character(x)) {
    return(is.character(y))
  }

  if (is.character(y)) {
    return(is.character(x))
  }

  tryCatch({
    comparison(x, y)
    TRUE
  },
  error = function(e) FALSE,
  warning = function(w) FALSE)
}
