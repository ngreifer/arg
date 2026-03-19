#' Check Argument Class
#'
#' @description
#' Checks whether an argument is a of a specified class (`arg_is()`) or is not of a specified class (`arg_is_not()`).
#'
#' @param x the argument to be checked
#' @param class a character vector of one or more classes to check `x` against.
#' @param .arg the name of the argument supplied to `x` to appear in error messages. The default is to extract the argument's name using [rlang::caller_arg()]. Ignored if `.msg` is supplied.
#' @param .msg an optional alternative message to display if an error is thrown instead of the default message.
#'
#' @details
#' `arg_is()` and `arg_is_not()` use [inherits()] to test for class membership. `arg_is()` throws an error only if no elements of `class(x)` are in `class`. `arg_is_not()` throws an error if any elements of `class(x)` are in `class`.
#'
#' Sometimes this can be too permissive; combining `arg_is()` with [arg_and()] can be useful for requiring that an object is of multiple classes. Alternatively, combining `arg_is_not()` with [arg_or()] can be useful for requiring that an object is not a specific combination of classes. See Examples.
#'
#' @return
#' Returns `NULL` invisibly if an error is not thrown.
#'
#' @seealso [inherits()], [arg_or()]; [arg_data()] for testing for specific kinds of objects (vectors, matrices, data frames, and lists)
#'
#' @examples
#' obj <- structure(list(1),
#'                  class = "test")
#'
#' try(arg_is(obj, "test"))            # No error
#' try(arg_is(obj, c("test", "quiz"))) # No error
#' try(arg_is(obj, "quiz"))            # Error
#'
#' try(arg_is_not(obj, "test"))            # Error
#' try(arg_is_not(obj, c("test", "quiz"))) # Error
#' try(arg_is_not(obj, "quiz"))            # No error
#'
#' # Multiple classes
#' obj2 <- structure(list(1),
#'                   class = c("test", "essay"))
#'
#' try(arg_is(obj2, c("test", "quiz")))     # No error
#' try(arg_is_not(obj2, c("test", "quiz"))) # Error
#'
#' ## Require argument to be of multiple classes
#' try(arg_and(obj2,
#'             arg_is("test"),
#'             arg_is("quiz")))
#'
#' ## Require argument to not be a specific combination of
#' ## multiple classes
#' try(arg_or(obj2,
#'            arg_is_not("test"),
#'            arg_is_not("essay")))

#' @export
arg_is <- function(x, class,
                   .arg = rlang::caller_arg(x), .msg = NULL) {
  arg_supplied(class)
  arg_character(class)

  if (!inherits(x, class)) {
    err(.msg %or% "{.arg {(.arg)}} must inherit from class {.or {.cls {class}}}")
  }
}

#' @export
#' @rdname arg_is
arg_is_not <- function(x, class,
                       .arg = rlang::caller_arg(x), .msg = NULL) {
  arg_supplied(class)
  arg_character(class)

  if (inherits(x, class)) {
    err(.msg %or% "{.arg {(.arg)}} must not inherit from class {.or {.cls {class}}}")
  }
}
