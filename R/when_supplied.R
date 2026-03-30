#' Check Arguments When Supplied
#'
#' These functions check arguments only when they are supplied (`when_supplied()`) or when not `NULL` (`when_not_null()`). Multiple checks can be applied in sequence. This allows arguments not to have to be supplied, but checks them only if they are.
#'
#' @inheritParams arg_is
#' @param \dots `arg_*()` functions or unevaluated function calls to be applied to `x`. See Examples.
#'
#' @details
#' An error will be thrown only if `x` is supplied and fails one of the supplied checks (`when_supplied()`) or is not `NULL` and fails one of the supplied checks (`when_not_null()`).
#'
#' The `...` arguments can be passed either as functions, e.g.,
#' ```
#' when_supplied(x,
#'               arg_number,
#'               arg_gt)
#' ```
#' or as unevaluated function calls with the `x` argument absent, e.g.,
#' ```
#' when_supplied(x,
#'               arg_number(),
#'               arg_gt(bound = 0))
#' ```
#' or as a mixture of both.
#'
#' `when_supplied()` only makes sense to use for an argument that has no default value but which can be omitted. `when_not_null()` makes sense to use for an argument with a default value of `NULL`.
#'
#' @inherit arg_is return
#'
#' @seealso [arg_or()], [arg_supplied()]
#'
#' @examples
#' f <- function(z) {
#'   when_supplied(z,
#'                 arg_number,
#'                 arg_between(c(0, 1)))
#' }
#'
#' try(f())    # No error: not supplied
#' try(f("a")) # Error: not a number
#' try(f(2))   # Error: not within 0-1 range
#' try(f(.7))  # No error: number within range
#'
#' g <- function(z = NULL) {
#'   when_not_null(z,
#'                 arg_number,
#'                 arg_between(c(0, 1)))
#' }
#'
#' try(g())     # No error: NULL okay
#' try(g(NULL)) # No error: NULL okay
#' try(g("a"))  # Error: not a number
#' try(g(2))    # Error: not within 0-1 range
#' try(g(.7))   # No error: number within range

#' @export
when_supplied <- function(x, ..., .arg = rlang::caller_arg(x), .call) {
  if (!rlang::is_missing(x)) {
    force(.arg)
    arg_dots_supplied(..., .call = rlang::current_env())

    dots <- rlang::call_match(dots_expand = FALSE)[["..."]]

    for (i in seq_along(dots)) {
      test <- .to_arg_fun_call(dots[[i]]) |>
        eval() |>
        try(silent = TRUE)

      if (inherits(test, "try-error")) {
        .msg <- conditionMessage(attr(test, "condition")) |>
          cli::ansi_strsplit("\n") |>
          unlist(recursive = FALSE)

        .msg[1L] <- paste("When {.arg {(.arg)}} is supplied,", ansi_lower_first(.msg[1L]))

        err(.msg, .call = .call)
      }
    }
  }
}

#' @export
#' @rdname when_supplied
when_not_null <- function(x, ..., .arg = rlang::caller_arg(x), .call) {
  if (is_not_null(x)) {
    force(.arg)
    arg_dots_supplied(..., .call = rlang::current_env())

    dots <- rlang::call_match(dots_expand = FALSE)[["..."]]

    for (i in seq_along(dots)) {
      test <- .to_arg_fun_call(dots[[i]]) |>
        eval() |>
        try(silent = TRUE)

      if (inherits(test, "try-error")) {
        .msg <- conditionMessage(attr(test, "condition")) |>
          cli::ansi_strsplit("\n") |>
          unlist(recursive = FALSE)

        .msg[1L] <- paste(cli::format_inline("When {.arg {(.arg)}} is not {.val {list(NULL)}},"),
                          ansi_lower_first(.msg[1L]))

        err(.msg, .call = .call)
      }
    }
  }
}

.to_arg_fun_call <- function(arg_call) {
  if (!is.call(arg_call) ||
      any_apply(as.list(arg_call), identical, as.name("::")) ||
      any_apply(as.list(arg_call), identical, as.name(":::"))) {
    arg_call <- rlang::call2(arg_call)
  }

  fmls <- rlang::fn_fmls_names(rlang::call_fn(arg_call))

  if ("x" %in% fmls && !("x" %in% rlang::call_args_names(arg_call))) {
    arg_call <- rlang::call_modify(arg_call, !!!list(x = quote(x)))
  }

  if (".arg" %in% fmls && !(".arg" %in% rlang::call_args_names(arg_call))) {
    arg_call <- rlang::call_modify(arg_call, !!!list(.arg = quote(.arg)))
  }

  if (".call" %in% fmls) {
    arg_call <- rlang::call_modify(arg_call, !!!list(.call = NULL))
  }

  rlang::call_match(call = arg_call, fn = rlang::call_fn(arg_call))
}
