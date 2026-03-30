#' Check Numeric Argument
#'
#' @description
#' Checks whether an argument is numeric, with some additional constraints if desired. `arg_numeric()` simply checks whether the argument is numeric. `arg_number()` checks whether the argument is a numeric scalar (i.e., a single number). `arg_whole_numeric()` and `arg_whole_number()` check whether the argument is a whole numeric vector or scalar, respectively. `arg_counts()` and `arg_count()` check whether the argument is a non-negative whole numeric vector or scalar, respectively.
#'
#' @inheritParams arg_is
#'
#' @details
#' A whole number is decided by testing whether the value is an integer (i.e., using [is.integer()]) or if `abs(x - trunc(x)) < sqrt(.Machine$double.eps)`. This is the same tolerance used by [all.equal()] to compare values.
#'
#' @inherit arg_is return
#'
#' @seealso [is.integer()], [rlang::is_integerish()]
#'
#' @examples
#' count <- 3
#' whole <- -4
#' num <- .943
#'
#' try(arg_number(count))       # No error
#' try(arg_whole_number(count)) # No error
#' try(arg_count(count))        # No error
#'
#' try(arg_number(whole))       # No error
#' try(arg_whole_number(whole)) # No error
#' try(arg_count(whole))        # Error: negatives not allowed
#'
#' try(arg_number(num))       # No error
#' try(arg_whole_number(num)) # Error: not a whole number
#' try(arg_count(num))        # Error: not a count
#'
#' nums <- c(0, .5, 1)
#'
#' try(arg_number(nums))  # Error: not a single number
#' try(arg_numeric(nums)) # No error
#' try(arg_counts(nums))  # Error: not counts

#' @export
arg_numeric <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                        .call) {
  if (!is.numeric(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a numeric vector",
        .call = .call)
  }
}

#' @export
#' @rdname arg_numeric
arg_number <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                       .call) {
  if (!is.numeric(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a number",
        .call = .call)
  }
  else if (length(x) != 1L) {
    err(.msg %or% "{.arg {(.arg)}} must be a single number",
        .call = .call)
  }
}

#' @export
#' @rdname arg_numeric
arg_whole_numeric <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                              .call) {
  if (!is.numeric(x) ||
      (!is.integer(x) && !all(check_if_zero(x - round(x))))) {
    err(.msg %or% "{.arg {(.arg)}} must be a whole numeric vector",
        .call = .call)
  }
}

#' @export
#' @rdname arg_numeric
arg_whole_number <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                             .call) {
  if (!is.numeric(x) ||
      (!is.integer(x) && !check_if_zero(x - round(x)))) {
    err(.msg %or% "{.arg {(.arg)}} must be a whole number",
        .call = .call)
  }

  if (length(x) != 1L) {
    err(.msg %or% "{.arg {(.arg)}} must be a single whole number",
        .call = .call)
  }
}

#' @export
#' @rdname arg_numeric
arg_counts <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                       .call) {
  if (!is.numeric(x) ||
      (!is.integer(x) && !all(check_if_zero(x - round(x)))) ||
      any(x < 0)) {
    err(.msg %or% "{.arg {(.arg)}} must be a vector of counts (non-negative whole numeric values)",
        .call = .call)
  }
}

#' @export
#' @rdname arg_numeric
arg_count <- function(x, .arg = rlang::caller_arg(x), .msg = NULL,
                      .call) {
  if (!is.numeric(x) ||
      (!is.integer(x) && !all(check_if_zero(x - round(x)))) ||
      any(x < 0)) {
    err(.msg %or% "{.arg {(.arg)}} must be a count (a non-negative whole number)",
        .call = .call)
  }

  if (length(x) != 1L) {
    err(.msg %or% "{.arg {(.arg)}} must be a single count (a non-negative whole number)",
        .call = .call)
  }
}


