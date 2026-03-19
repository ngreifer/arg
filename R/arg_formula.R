#' Check Formula Argument
#'
#' @description
#' Checks whether an argument is a [`formula`].
#'
#' @inheritParams arg_is
#' @param one_sided `NULL` or `logical`; if `TRUE`, checks that `x` is a `formula` with only one side (the right side); if `FALSE`, checks that `x` is a `formula` with both sides; if `NULL` (the default), checks only that `x` is a `formula.`
#'
#' @inherit arg_is return
#'
#' @seealso [rlang::is_formula()], [arg_is()]
#'
#' @examples
#' form1 <- ~a + b
#' form2 <- y ~ a + b
#' not_form <- 1:3
#'
#' try(arg_formula(form1))    # No error
#' try(arg_formula(form2))    # No error
#' try(arg_formula(not_form)) # Error: not a formula
#'
#' try(arg_formula(form1,
#'                 one_sided = TRUE)) # No error
#' try(arg_formula(form2,
#'                 one_sided = TRUE)) # Error, not one-sided
#'
#' try(arg_formula(form1,
#'                 one_sided = FALSE)) # Error, only one-sided
#' try(arg_formula(form2,
#'                 one_sided = FALSE)) # No error

#' @export
arg_formula <- function(x, one_sided = NULL,
                        .arg = rlang::caller_arg(x), .msg = NULL) {

  if (is_null(one_sided)) {
    if (!rlang::is_formula(x)) {
      err(.msg %or% "{.arg {(.arg)}} must be a formula")
    }
  }
  else {
    arg_flag(one_sided)

    if (!rlang::is_formula(x, lhs = !one_sided)) {
      sides <- if (one_sided) "one" else "two"
      err(.msg %or% "{.arg {(.arg)}} must be a {sides}-sided formula")
    }
  }
}
