#' Check That Arguments Meet Some or All Criteria
#'
#' `arg_or()` checks whether an argument meets at least one given criterion. `arg_and()` checks whether an argument meets all given criteria.
#'
#' @inheritParams when_supplied
#' @inheritParams arg_is
#'
#' @details
#' For `arg_or()`, an error will be thrown only if `x` fails all of the supplied checks. This can be useful when an argument can take on one of several input types. For `arg_and()`, and error will be thrown if `x` fails any of the supplied checks. This is less useful on its own, as the checks can simply occur in sequence without `arg_and()`, but `arg_and()` can be supplied to the `...` argument of `arg_or()` to create more complicated criteria.
#'
#' The `...` arguments can be passed either as functions, e.g.,
#' ```
#' arg_or(x,
#'        arg_number,
#'        arg_string,
#'        arg_flag)
#' ```
#' or as unevaluated function calls with the `x` argument absent, e.g.,
#' ```
#' arg_or(x,
#'        arg_number(),
#'        arg_string(),
#'        arg_flag())
#' ```
#' or as a mixture of both.
#'
#' These functions do their best to provide a clean error message composed of all the error messages for the failed checks. With many options, this can yield a complicated error message, so use caution. `arg_and()` marks with a check (```r cli::symbol$tick```) any passed checks and with an x (```r cli::symbol$cross```) any failed checks.
#'
#' @inherit arg_is return
#'
#' @seealso [arg_supplied()], [when_not_null()]
#'
#' @examples
#' # `arg_or()`
#' f <- function(z) {
#'   arg_or(z,
#'          arg_number,
#'          arg_string,
#'          arg_flag)
#' }
#'
#' try(f(1))      # No error
#' try(f("test")) # No error
#' try(f(TRUE))   # No error
#' try(f(1:4))    # Error: neither a number, string,
#' #              #        or flag, but a vector
#'
#' # `arg_and()`
#' g <- function(z) {
#'   arg_and(z,
#'           arg_counts,
#'           arg_length(len = 2),
#'           arg_lt(bound = 5))
#' }
#'
#' try(g(c(1, 2)))     # No error
#' try(g(c(1, 7)))     # Error: not < 5
#' try(g(c(1.1, 2.1))) # Error: not counts
#' try(g(4))           # Error: not length 2
#' try(g("bad"))       # Error: no criteria satisfied
#'
#' # Chaining together `arg_and()` and `arg_or()`
#' h <- function(z) {
#'   arg_or(z,
#'          arg_all_NA,
#'          arg_and(arg_count,
#'                  arg_lt(5)),
#'          arg_and(arg_string,
#'                  arg_element(c("a", "b", "c"))))
#' }
#'
#' try(h(NA))  # No error
#' try(h(1))   # No error
#' try(h("a")) # No error
#' try(h(7))   # Error: not < 5
#' try(h("d")) # Error: not in "a", "b", or "c"

#' @export
arg_or <- function(x, ..., .arg = rlang::caller_arg(x), .msg = NULL, .call) {
  force(.arg)

  if (...length() == 0L) {
    return(invisible())
  }

  dots <- rlang::call_match(dots_expand = FALSE)[["..."]]

  failures <- character(...length())

  for (i in seq_along(dots)) {
    j <- .to_arg_fun_call(dots[[i]])

    test <- try(eval(j), silent = TRUE)

    if (!inherits(test, "try-error")) {
      return(invisible())
    }

    failures[i] <- conditionMessage(attr(test, "condition"))
  }

  if (is_not_null(.msg)) {
    err(.msg, .call = .call)
  }

  grouped_msgs <- group_messages(failures, "or")
  grouped <- attr(grouped_msgs, "grouped")

  for (i in which(!grouped)) {
    msg_i <- failures[i]

    if (cli::ansi_grepl("^at least one of the following conditions must be met:", msg_i,
                        ignore.case = TRUE)) {

      msg_i <- Reduce(function(m, j) unlist(strsplit(m, j, TRUE)),
                      as.list(unlist(cli::symbol)),
                      init = msg_i) |>
        unlist() |>
        cli::ansi_trimws()

      grouped_msgs_i <- group_messages(msg_i[-1], "or")
      grouped_i <- attr(grouped_msgs_i, "grouped")

      grouped_msgs <- c(grouped_msgs,
                        grouped_msgs_i,
                        msg_i[-1L][!grouped_i] |>
                          cli::ansi_trimws() |>
                          trim_final_punct() |>
                          ansi_lower_first() |>
                          cli::ansi_collapse())
    }
    else if (cli::ansi_grepl("^all of the following conditions must be met:", msg_i,
                             ignore.case = TRUE)) {

      msg_i <- Reduce(function(m, j) unlist(strsplit(m, j, TRUE)),
                      as.list(unlist(cli::symbol)),
                      init = msg_i) |>
        unlist() |>
        cli::ansi_trimws()

      grouped_msgs_i <- group_messages(msg_i[-1], "and")
      grouped_i <- attr(grouped_msgs_i, "grouped")

      grouped_msgs <- c(grouped_msgs,
                        grouped_msgs_i,
                        msg_i[-1L][!grouped_i] |>
                          cli::ansi_trimws() |>
                          trim_final_punct() |>
                          ansi_lower_first() |>
                          cli::ansi_collapse(", and "))
    }
    else {
      grouped_msgs <- c(grouped_msgs,
                        msg_i |>
                          cli::ansi_trimws() |>
                          trim_final_punct() |>
                          ansi_lower_first())
    }
  }

  n_err <- sum(nzchar(grouped_msgs))

  if (n_err == 1L) {
    err(grouped_msgs[nzchar(grouped_msgs)],
        .call = .call)
  }

  err(c("At least one of the following conditions must be met:",
        setNames(grouped_msgs[nzchar(grouped_msgs)],
                 rep.int("*", n_err))),
      .call = .call)
}

#' @export
#' @rdname arg_or
arg_and <- function(x, ..., .arg = rlang::caller_arg(x), .msg = NULL, .call) {
  force(.arg)

  dots <- rlang::call_match(dots_expand = FALSE)[["..."]]

  failures <- character(...length())
  failed <- rep.int(FALSE, ...length())

  for (i in seq_along(dots)) {
    test <- .to_arg_fun_call(dots[[i]]) |>
      eval() |>
      try(silent = TRUE)

    if (inherits(test, "try-error")) {
      failures[i] <- conditionMessage(attr(test, "condition"))
      failed[i] <- TRUE
    }
  }

  if (!any(failed)) {
    return(invisible())
  }

  if (is_not_null(.msg)) {
    err(.msg, .call = .call)
  }

  ## Get error messages for non-failures
  for (i in which(!failed)) {
    test <- .to_arg_fun_call(dots[[i]]) |>
      make_fail(x) |>
      eval() |>
      try(silent = TRUE)

    if (inherits(test, "try-error")) {
      failures[i] <- conditionMessage(attr(test, "condition"))
    }
  }

  dup <- duplicated(failures) | !nzchar(failures)
  failures <- failures[!dup]
  failed <- failed[!dup]

  for (i in seq_along(failures)) {
    msg_i <- failures[i]

    if (cli::ansi_grepl("^at least one of the following conditions must be met:", msg_i,
                        ignore.case = TRUE)) {

      msg_i <- Reduce(function(m, j) unlist(strsplit(m, j, TRUE)),
                      as.list(unlist(cli::symbol)),
                      init = msg_i) |>
        unlist() |>
        cli::ansi_trimws()

      failures[i] <- msg_i[-1L] |>
        cli::ansi_trimws() |>
        trim_final_punct() |>
        ansi_lower_first() |>
        cli::ansi_collapse(last = ", or ")
    }
    else if (cli::ansi_grepl("^all of the following conditions must be met:", msg_i,
                             ignore.case = TRUE)) {

      msg_i <- Reduce(function(m, j) unlist(strsplit(m, j, TRUE)),
                      as.list(unlist(cli::symbol)),
                      init = msg_i) |>
        unlist() |>
        cli::ansi_trimws()

      failures[i] <- msg_i[-1L] |>
        cli::ansi_trimws() |>
        trim_final_punct() |>
        ansi_lower_first() |>
        cli::ansi_collapse(", and ")
    }
    else {
      failures[i] <- msg_i |>
        trim_final_punct() |>
        cli::ansi_trimws()
    }
  }

  if (length(failures) == 1L) {
    err(failures, .call = .call)
  }

  err(c("All of the following conditions must be met:",
        setNames(failures, ifelse(failed, "x", "v"))),
      .call = .call)
}

group_messages <- function(messages, and_or = "and", .envir = parent.frame()) {
  prefixes <- .prefixes()
  grouped_msgs <- character(length(prefixes))
  grouped <- rep(FALSE, length(messages))

  for (i in seq_along(prefixes)) {
    prefix <- cli::format_inline(prefixes[i], .envir = .envir)
    starts_with_prefix <- cli::ansi_grepl(paste0("^", prefix), messages[!grouped])

    if (sum(starts_with_prefix) < 2L) {
      next
    }

    if (endsWith(prefix, " a")) {
      offset <- rep(0:1, c(1L, sum(starts_with_prefix) - 1L))
    }
    else {
      offset <- 0
    }

    grouped_msgs[i] <- paste(prefix,
                             messages[!grouped][starts_with_prefix] |>
                               ansi_trim(cli::ansi_nchar(prefix) - offset) |>
                               trim_final_punct() |>
                               cli::ansi_trimws() |>
                               cli::ansi_collapse(last = sprintf(", %s ", and_or)))

    grouped[!grouped][starts_with_prefix] <- TRUE

    if (all(grouped)) {
      break
    }
  }

  attr(grouped_msgs, "grouped") <- grouped

  grouped_msgs
}

.prefixes <- function() {
  p <- c(#"{.arg {(.arg)}} must be a",
    "{.arg {(.arg)}} must inherit from",
    "{.arg {(.arg)}} must be",
    "{.arg {(.arg)}} must have",
    # "{.arg {(.arg)}} must",
    "{.arg {(.arg)}}")

  c(p, paste("each element of", p))
}
