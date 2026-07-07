#' Check Index Argument
#'
#' @description
#' Checks whether an argument is a valid column index or name (`arg_index()`) of a dataset or a vector of valid column indices or names (`arg_indices()`). `arg_name()` and `arg_names()` additionally require that the argument is a string or character, respectively.
#'
#' @inheritParams arg_is
#' @param data a dataset (i.e., a matrix or data frame) or other vector-like object.
#' @param .arg_data the name of the argument supplied to `data` to appear in error messages. The default is to extract the argument's name using [rlang::caller_arg()]. Ignored if `.msg` is supplied.
#'
#' @details
#' For `arg_indices()`, an error will be thrown unless one of the following are true:
#'
#' * `x` is a vector of counts (see [arg_counts()]) less than or equal to `ncol(data)` (or `length(data)` if `data` is not a dataset)
#' * `x` is a character vector with values a subset of `colnames(data)` (or `names(data)` if `data` is not a dataset)
#'
#' For `arg_index()`, `x` additionally must have length equal to 1. Passing `arg_index()` ensures that `data[, x]` (if `data` is a matrix) or `data[[x]]` (otherwise) evaluate correctly. For `arg_name()` and `arg_names()`, an error will be thrown unless `x` is additionally a string or character vector, respectively.
#'
#' If `data` is a dataset with no column names or otherwise has no names, an error will be thrown if `x` is a character vector.
#'
#' @inherit arg_is return
#'
#' @seealso
#' [arg_counts()], [arg_character()]
#'
#' [arg_named()] for checking whether a dataset or other object has names.
#'
#' @examples
#' dat <- data.frame(col1 = 1:5,
#'                   col2 = 6:10)
#'
#' f1 <- function(z) {
#'   arg_index(z, dat)
#' }
#'
#' try(f1(1))         # No error
#' try(f1(3))         # Error: not a valid index
#' try(f1("col1"))    # No error
#' try(f1("bad_col")) # Error: not a valid index
#' try(f1(1:2))       # Error: arg_index() requires scalar
#'
#' f2 <- function(z) {
#'   arg_name(z, dat)
#' }
#'
#'
#' try(f2("col1"))            # No error
#' try(f2(1))                 # Error: not a string
#' try(f2("bad_col"))         # Error: not a valid name
#' try(f2(c("col1", "col2"))) # Error: arg_name() requires scalar
#'
#' mat <- matrix(1:9, ncol = 3)
#'
#' g <- function(z) {
#'   arg_indices(z, mat)
#' }
#'
#' try(g(1))     # No error
#' try(g(1:3))   # No error
#' try(g("col")) # Error: `mat` has no names

#' @export
arg_index <- function(x, data,
                      .arg = rlang::caller_arg(x),
                      .arg_data = rlang::caller_arg(data),
                      .msg = NULL, .call) {
  arg_supplied(data, .call = rlang::current_env()) |>
    internal_arg()

  if (identical(length(dim(data)), 2L)) {
    is_valid_num_index <- rlang::is_integerish(x) && all(x >= 1L) && all(x <= ncol(data))

    is_valid_char_index <- !is_valid_num_index &&
      is_not_null(colnames(data)) &&
      is.character(x) &&
      all(x %in% colnames(data))

    var <- "column"
  }
  else {
    is_valid_num_index <- rlang::is_integerish(x) && all(x >= 1L) && all(x <= length(data))

    is_valid_char_index <- !is_valid_num_index &&
      is_not_null(names(data)) &&
      is.character(x) &&
      all(x %in% names(data))

    var <- "element"
  }

  if (!is_scalar(x) || (!is_valid_num_index && !is_valid_char_index)) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    if (var == "column") {
      if (is_null(colnames(data))) {
        err("{.arg {(.arg)}} must be the index of a column in {.arg {(.arg_data)}}",
            .call = .call)
      }

      err("{.arg {(.arg)}} must be the name or index of a column in {.arg {(.arg_data)}}",
          .call = .call)
    }

    if (var == "element") {
      if (is_null(names(data))) {
        err("{.arg {(.arg)}} must be the index of an element in {.arg {(.arg_data)}}",
            .call = .call)
      }

      err("{.arg {(.arg)}} must be the name or index of an element in {.arg {(.arg_data)}}",
          .call = .call)
    }
  }
}

#' @export
#' @rdname arg_index
arg_indices <- function(x, data,
                        .arg = rlang::caller_arg(x),
                        .arg_data = rlang::caller_arg(data),
                        .msg = NULL, .call) {
  arg_supplied(data, .call = rlang::current_env()) |>
    internal_arg()

  if (identical(length(dim(data)), 2L)) {
    is_valid_num_index <- rlang::is_integerish(x) && all(x >= 1L) && all(x <= ncol(data))

    is_valid_char_index <- !is_valid_num_index &&
      is_not_null(colnames(data)) &&
      is.character(x) &&
      all(x %in% colnames(data))

    var <- "column"
  }
  else {
    is_valid_num_index <- rlang::is_integerish(x) && all(x >= 1L) && all(x <= length(data))

    is_valid_char_index <- !is_valid_num_index &&
      is_not_null(names(data)) &&
      is.character(x) &&
      all(x %in% names(data))

    var <- "element"
  }

  if (!is_valid_num_index && !is_valid_char_index) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    if (var == "column") {
      if (is_null(colnames(data))) {
        err("{.arg {(.arg)}} must be {cli::qty(length(x))} {?the/a vector of} ind{?ex/ices} of {?a/} column{?s} in {.arg {(.arg_data)}}",
            .call = .call)
      }

      err("{.arg {(.arg)}} must be {cli::qty(length(x))} {?the/a vector of} name{?s} or ind{?ex/ices} of {?a/} column{?s} in {.arg {(.arg_data)}}",
          .call = .call)
    }
    else {
      if (is_null(names(data))) {
        err("{.arg {(.arg)}} must be {cli::qty(length(x))} {?the/a vector of} ind{?ex/ices} of {?an/} element{?s} in {.arg {(.arg_data)}}",
            .call = .call)
      }

      err("{.arg {(.arg)}} must be {cli::qty(length(x))} {?the/a vector of} name{?s} or ind{?ex/ices} of {?an/} element{?s} in {.arg {(.arg_data)}}",
          .call = .call)
    }
  }
}

#' @export
#' @rdname arg_index
arg_name <- function(x, data,
                     .arg = rlang::caller_arg(x),
                     .arg_data = rlang::caller_arg(data),
                     .msg = NULL, .call) {
  arg_supplied(data, .call = rlang::current_env()) |>
    internal_arg()

  if (identical(length(dim(data)), 2L)) {
    arg_colnamed(data, .call = rlang::current_env()) |>
      internal_arg()

    is_valid_char_index <- is.character(x) &&
      all(x %in% colnames(data))

    var <- "column"
  }
  else {
    arg_named(data, .call = rlang::current_env()) |>
      internal_arg()

    is_valid_char_index <- is.character(x) &&
      all(x %in% names(data))

    var <- "element"
  }

  if (!is_scalar(x) || !is_valid_char_index) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    if (var == "column") {
      err("{.arg {(.arg)}} must be the name of a column in {.arg {(.arg_data)}}",
          .call = .call)
    }
    else {
      err("{.arg {(.arg)}} must be the name of an element in {.arg {(.arg_data)}}",
          .call = .call)
    }
  }
}

#' @export
#' @rdname arg_index
arg_names <- function(x, data,
                      .arg = rlang::caller_arg(x),
                      .arg_data = rlang::caller_arg(data),
                      .msg = NULL, .call) {
  arg_supplied(data, .call = rlang::current_env()) |>
    internal_arg()

  if (identical(length(dim(data)), 2L)) {
    arg_colnamed(data, .call = rlang::current_env()) |>
      internal_arg()

    is_valid_char_index <- is.character(x) &&
      all(x %in% colnames(data))

    var <- "column"
  }
  else {
    arg_named(data, .call = rlang::current_env()) |>
      internal_arg()

    is_valid_char_index <- is.character(x) &&
      all(x %in% names(data))

    var <- "element"
  }

  if (!is_valid_char_index) {

    if (is_not_null(.msg)) {
      err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
    }

    if (var == "column") {
      err("{.arg {(.arg)}} must be {cli::qty(length(x))} {?the/a vector of} name{?s} of {?a/} column{?s} in {.arg {(.arg_data)}}",
          .call = .call)
    }
    else {
      err("{.arg {(.arg)}} must be {cli::qty(length(x))} {?the/a vector of} name{?s} of {?an/} element{?s} in {.arg {(.arg_data)}}",
          .call = .call)
    }
  }
}
