#' Throw an Error, Warning, or Message
#'
#' These functions are similar to [stop()]/[cli::cli_abort()], [warning()]/[cli::cli_warn()], and [message()]/[cli::cli_inform()], throwing an error, warning, and message, respectively. Minor processing is done to capitalize the first letter of the message, add a period at the end (if it makes sense to), and add information about the calling function.
#'
#' @param m the message to be displayed, passed to the `message` argument of [rlang::abort()], [rlang::warn()], or [rlang::inform()].
#' @param .call the execution environment of a currently running function, e.g. `.call = rlang::current_env()`. The corresponding function call is retrieved and mentioned in error messages as the source of the error. See the `call` argument of [rlang::abort()] for details. Set to `NULL` to omit call information. The default is to search along the call stack for the first user-facing function in another package, if any.
#' @param .envir the environment to evaluate the glue expressions in. See [rlang::abort()] for details. Typically this does not need to be changed.
#' @param immediate whether to output the warning immediately (`TRUE`, the default) or save all warnings until the end of execution (`FALSE`). See [warning()] for details. Note that the default here differs from that of `warning()`.
#'
#' @details
#' These functions are simple wrappers for the corresponding functions in \pkg{rlang}, namely [rlang::abort()] for `err()`, [rlang::warn()] for `wrn()`, and [rlang::inform()] for `msg()`, but which function almost identically to the \pkg{cli} versions. Their main differences are that they additionally process the input (capitalizing the first character of the message and adding a period to the end if needed, unless multiple strings are provided). `err()` is used inside all `arg_*()` functions in \pkg{arg}.
#'
#' @return
#' `err()` throws an error condition. `wrn()` throws a warning condition and invisibly returns the formatted warning message as a string. `msg()` signals a message and invisibly returns `NULL`.
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
err <- function(m, .call, .envir = rlang::caller_env()) {

  arg_env(.envir, .call = rlang::current_env())

  if (rlang::is_missing(.call)) {
    .call <- .pkg_caller_call()
  }

  for (i in seq_along(m)) {
    m[i] <- cli::format_inline(m[i], .envir = .envir)
  }

  m[] <- .tidy_msg(m) |>
    cli::ansi_simplify()

  rlang::abort(m, call = .call, use_cli_format = TRUE,
               .frame = .envir)
}

#' @export
#' @rdname err
wrn <- function(m, immediate = TRUE, .envir = rlang::caller_env()) {
  arg_flag(immediate, .call = rlang::current_env())
  arg_env(.envir, .call = rlang::current_env())

  if (isTRUE(immediate) && isTRUE(all.equal(0, getOption("warn")))) {
    rlang::local_options(warn = 1)
  }

  cli::format_warning(m, .envir = .envir) |>
    .tidy_msg() |>
    cli::ansi_simplify() |>
    rlang::warn()
}

#' @export
#' @rdname err
msg <- function(m, .envir = rlang::caller_env()) {
  arg_env(.envir, .call = rlang::current_env())

  cli::format_message(m, .envir = .envir) |>
    .tidy_msg() |>
    cli::ansi_simplify() |>
    rlang::inform()
}

# Capitalize first character (if letter), add period at the end
# (if no other ending punctuation)
.tidy_msg <- function(m) {
  if (length(m) != 1L) {
    return(m)
  }

  # Capitalize first letter
  m[] <- ansi_upper_first(m)

  # Add period to end
  if (!cli::ansi_grepl("([.]|[?]|[!])$", m)) {
    m[] <- paste0(m, ".")
  }

  m
}

.pkg_caller_call <- function() {
  nf <- sys.nframe()

  arg <- utils::packageName()

  .pkg_names <- character(nf)
  pkg_name <- NULL

  # Get packahges names for all calls in the stack
  for (i in seq_len(nf)) {
    fn <- sys.function(i)

    if (!is.function(fn)) {
      next
    }

    env <- environment(fn)

    if (identical(env, globalenv())) {
      next
    }

    .pkg_names[i] <- environmentName(env)
  }

  .pkg_ignore <- c("", arg, "rlang", "base")

  if (all(.pkg_names %in% .pkg_ignore)) {
    return(NULL)
  }

  # Find block of arg, then block of other package; that
  # package's namespace is searched

  arg_passed <- FALSE
  fn_ind <- NULL
  pkg_name <- NULL

  for (i in seq(nf, 1L)) {
    if (!arg_passed) {
      if (.pkg_names[i] == arg) {
        arg_passed <- TRUE
      }

      next
    }

    if (is_null(fn_ind)) {
      if (!.pkg_names[i] %in% .pkg_ignore) {
        pkg_found <- TRUE
        fn_ind <- i
      }

      next
    }

    if (.pkg_names[i] != .pkg_names[fn_ind]) {
      break
    }

    fn_ind <- i
  }

  if (is_null(fn_ind)) {
    return(NULL)
  }

  pkg_name <- .pkg_names[fn_ind]

  pkg_funs <- c(getNamespaceExports(pkg_name),
                .getNamespaceInfo(asNamespace(pkg_name), "S3methods")[, 3L])

  if (is_null(pkg_funs)) {
    return(NULL)
  }

  e <- sys.call(fn_ind)

  n <- rlang::call_name(e)

  if (is_null(n) || !n %in% pkg_funs) {
    return(NULL)
  }

  e
}
