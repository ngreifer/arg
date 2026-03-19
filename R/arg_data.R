#' Check Common Argument Types
#' @name arg_data
#'
#' @description
#' Checks whether an argument is an atomic vector (`arg_atomic()`), a dimensionless atomic vector (`arg_vector()`), a [`list`] (`arg_list()`), a [data frame][data.frame] (`arg_data.frame()`), a [`matrix`] (`arg_matrix()`), an [`array`] (`arg_array()`), a rectangular data set (`arg_data()`), or an [`environment`] (`arg_env()`).
#'
#' @inheritParams arg_is
#' @param df_ok `logical`; whether to allow data frames (which are technically lists). Default is `FALSE` to throw an error on a data frame input.
#'
#' @details
#' Atomic vectors are checked using [is.atomic()]. Because matrices are considered atomic vectors, `arg_vector()` additionally checks that there is no `"dims"` attribute, i.e., that `length(dim(x)) == 0L`. `arg_data()` checks whether `x` is either a data frame or a matrix. `arg_list()` checks whether `x` is a list; when `df = FALSE`, it throws an error when `x` is a data frame, even though data frames are lists.
#'
#' @inherit arg_is return
#'
#' @seealso [is.atomic()], [is.list()], [is.data.frame()], [is.matrix()], [is.array()], [is.environment()], [arg_is()]
#'
#' @examples
#' vec <- 1:6
#' mat <- as.matrix(vec)
#' dat <- as.data.frame(mat)
#' lis <- as.list(vec)
#' nul <- NULL
#'
#' # arg_atomic()
#' try(arg_atomic(vec))
#' try(arg_atomic(mat))
#' try(arg_atomic(dat))
#' try(arg_atomic(lis))
#' try(arg_atomic(nul))
#'
#' # arg_vector()
#' try(arg_vector(vec))
#' try(arg_vector(mat))
#'
#' # arg_matrix()
#' try(arg_matrix(vec))
#' try(arg_matrix(mat))
#' try(arg_matrix(dat))
#'
#' # arg_data.frame()
#' try(arg_data.frame(vec))
#' try(arg_data.frame(mat))
#' try(arg_data.frame(dat))
#'
#' # arg_data()
#' try(arg_data(vec))
#' try(arg_data(mat))
#' try(arg_data(dat))

#' @export
#' @rdname arg_data
arg_atomic <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.atomic(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be an atomic vector")
  }
}

#' @export
#' @rdname arg_data
arg_vector <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.atomic(x) || !is_null(dim(x))) {
    err(.msg %or% "{.arg {(.arg)}} must be a vector")
  }
}

#' @export
#' @rdname arg_data
arg_list <- function(x, df_ok = FALSE, .arg = rlang::caller_arg(x), .msg = NULL) {
  arg_flag(df_ok)

  if (!df_ok && is.data.frame(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a list and not a data frame")
  }

  if (!is.list(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a list")
  }
}

#' @export
#' @rdname arg_data
arg_data.frame <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.data.frame(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a data frame")
  }
}

#' @export
#' @rdname arg_data
arg_matrix <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.matrix(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a matrix")
  }
}

#' @export
#' @rdname arg_data
arg_array <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.array(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be an array")
  }
}

#' @export
#' @rdname arg_data
arg_data <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.data.frame(x) && !is.matrix(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be a data frame or matrix")
  }
}

#' @export
#' @rdname arg_data
arg_env <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (!is.environment(x)) {
    err(.msg %or% "{.arg {(.arg)}} must be an enviornment")
  }
}
