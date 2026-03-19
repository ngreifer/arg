#' Check Named Argument
#'
#' @description
#' Checks whether an argument has valid (non-`NULL`, non-empty, and non-`NA`) names.
#'
#' @inheritParams arg_is
#'
#' @details
#' `arg_named()` works for vectors, lists, and data frames. To check whether a matrix has column names, use `arg_colnamed()` (which also works for data frames, but not vectors or lists).
#'
#' @inherit arg_is return
#'
#' @seealso [rlang::is_named()], [names()], [colnames()], [arg_data()]
#'
#' @examples
#' obj <- c(1,
#'          B = 2,
#'          C = 3)
#'
#' try(arg_named(obj)) # Error: one name is blank
#'
#' names(obj)[1L] <- "A"
#' try(arg_named(obj)) # No error
#'
#' obj2 <- unname(obj)
#' try(arg_named(obj2)) # Error: no names
#'
#' # Matrix and data frame
#' mat <- matrix(1:6, ncol = 2L)
#' colnames(mat) <- c("A", "B")
#'
#' try(arg_named(mat))    # Error: matrices are not named
#' try(arg_colnamed(mat)) # No error
#'
#' dat <- as.data.frame(mat)
#' try(arg_named(dat))    # No error: data frames are named
#' try(arg_colnamed(dat)) # No error
#'
#' colnames(mat) <- NULL
#' try(arg_colnamed(mat)) # Error: no colnames

#' @export
arg_named <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (is_null(names(x)) || anyNA(names(x)) ||
      !all(nzchar(names(x)))) {
    err(.msg %or% "{.arg {(.arg)}} must have non-empty and non-{.val {NA}} names")
  }
}

#' @export
#' @rdname arg_named
arg_colnamed <- function(x, .arg = rlang::caller_arg(x), .msg = NULL) {
  if (is_null(colnames(x)) || anyNA(colnames(x)) ||
      !all(nzchar(colnames(x)))) {
    err(.msg %or% "{.arg {(.arg)}} must have non-empty and non-{.val {NA}} names")
  }
}
