#' Throw an Error, Warning, or Message
#'
#' These functions are similar to [stop()]/[cli::cli_abort()], [warning()]/[cli::cli_warn()], and [message()]/[cli::cli_inform()], throwing an error, warning, and message, respectively. Minor processing is done to capitalize the first letter of the message, add a period at the end (if it makes sense to), and add information about the calling function.
#'
#' @param m the message to be displayed, passed to the `message` argument of [rlang::abort()], [rlang::warn()], or [rlang::inform()].
#' @param call the execution environment of the function. The corresponding function call is retrieved and mentioned in error messages as the source of the error. See [rlang::abort()] for details.
#' @param .envir the environment to evaluate the glue expressions in. See [rlang::abort()] for details. Typically this does not need to be changed.
#' @param immediate whether to output the warning immediately (`TRUE`, the default) or save all warnings until the end of execution (`FALSE`). See [warning()] for details. Note that the default here differs from that of `warning()`.
#'
#' @details
#' These functions are simple wrappers for the corresponding functions in \pkg{rlang}, namely [rlang::abort()] for `err()`, [rlang::warn()] for `wrn()`, and [rlang::inform()] for `msg()`, but which function almost identically to the \pkg{cli} versions. Their main differences are that they additionally process the input (capitalizing the first character of the message and adding a period to the end if needed, unless multiple strings are provided). `err()` is used inside all `arg_*()` functions in \pkg{arg}.
#'
#' @seealso
#' * Base versions: [stop()], [warning()], [message()]
#' * \pkg{rlang} versions: [rlang::abort()], [rlang::warn()], [rlang::inform()]
#' * \pkg{cli} versions: [cli::cli_abort()], [cli::cli_warn()], [cli::cli_inform()]
#'
#' @examples
#' f <- function(x) {
#'   err("this is an error, and {.arg x} is {.type {x}}")
#' }
#'
#' try(f(1))
#'
#' g <- function(x) {
#'   wrn("this warning displayed last", immediate = FALSE)
#'   wrn("this warning displayed first")
#' }
#'
#' try(g(1))
#'
#' h <- function() {
#'   msg("is a period added at the end?")
#'   msg("not when the message ends in punctuation!")
#'   msg(c("or when multiple",
#'         "!" = "messages",
#'         "v" = "are",
#'         "*" = "displayed"))
#'   msg("otherwise yes")
#' }
#'
#' h()

#' @export
err <- function(m, call = rlang::caller_env(2), .envir = rlang::caller_env()) {
  m <- .tidy_msg(m)

  for (i in seq_along(m)) {
    m[i] <- cli::format_inline(m[i], .envir = .envir)
  }

  rlang::abort(m, call = call, use_cli_format = TRUE,
               .frame = .envir)
}

#' @export
#' @rdname err
wrn <- function(m, immediate = TRUE, .envir = rlang::caller_env()) {
  if (isTRUE(immediate) && isTRUE(all.equal(0, getOption("warn")))) {
    rlang::local_options(warn = 1)
  }

  .tidy_msg(m) |>
    cli::format_warning(.envir = .envir) |>
    rlang::warn()
}

#' @export
#' @rdname err
msg <- function(m, .envir = rlang::caller_env()) {
  .tidy_msg(m) |>
    cli::format_message(.envir = .envir) |>
    rlang::inform()
}

# Capitalize first character (if letter), add period at the end
# (if no other ending punctuation)
.tidy_msg <- function(m) {
  if (length(m) != 1L) {
    return(m)
  }

  # Capitalize first letter
  m <- ansi_upper_first(m)

  # Add period to end
  if (!cli::ansi_grepl("([.]|[?]|[!])$", m)) {
    m <- paste0(m, ".")
  }

  m
}

