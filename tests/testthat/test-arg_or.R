test_that("arg_or() passes if x satisfies at least one check, using bare function names", {
  f <- function(z) arg_or(z, arg_number, arg_string, arg_flag)
  expect_null(f(1))
  expect_null(f("test"))
  expect_null(f(TRUE))
  expect_error(f(1:4), "must be", fixed = TRUE)
})

test_that("arg_or() accepts unevaluated call syntax with x omitted", {
  f2 <- function(z) arg_or(z, arg_number(), arg_string(), arg_flag())
  expect_null(f2(1))
  expect_null(f2("test"))
  expect_error(f2(1:4))
})

test_that("arg_or() combines failure messages into a single readable error", {
  f <- function(z) arg_or(z, arg_number, arg_string, arg_flag)
  expect_error(f(1:4),
               "a single number, a string, or a single logical value", fixed = TRUE)
})

test_that("arg_or() with no checks supplied is a no-op", {
  expect_null(arg_or(1))
})

test_that("arg_and() passes only if x satisfies every check", {
  g <- function(z) arg_and(z, arg_counts, arg_length(len = 2), arg_lt(bound = 5))
  expect_null(g(c(1, 2)))
  expect_error(g(c(1, 7)), "Each element of `z` must be less than 5", fixed = TRUE)
  expect_error(g(c(1.1, 2.1)))
  expect_error(g(4))
})

test_that("arg_and() marks passed checks with a tick and failed checks with a cross", {
  g <- function(z) arg_and(z, arg_counts, arg_length(len = 2), arg_lt(bound = 5))
  cnd <- rlang::catch_cnd(g(c(1, 7)))
  msg <- conditionMessage(cnd)
  expect_match(msg, "All of the following conditions must be met", fixed = TRUE)

  tick <- cli::symbol$tick
  cross <- cli::symbol$cross

  expect_match(msg, paste0(tick, " `z` must be a vector of counts"), fixed = TRUE)
  expect_match(msg, paste0(tick, " `z` must have length 2"), fixed = TRUE)
  expect_match(msg, paste0(cross, " Each element of `z` must be less than 5"), fixed = TRUE)
})

test_that("arg_and() reports a single failure message directly, without a bulleted list", {
  g <- function(z) arg_and(z, arg_counts, arg_length(len = 2), arg_lt(bound = 5))
  expect_error(g("bad"), "All of the following conditions must be met", fixed = TRUE)
})

test_that("arg_and() and arg_or() can be chained together", {
  h <- function(z) {
    arg_or(z,
           arg_all_NA,
           arg_and(arg_count, arg_lt(5)),
           arg_and(arg_string, arg_element(c("a", "b", "c"))))
  }
  expect_null(h(NA))
  expect_null(h(1))
  expect_null(h("a"))
  expect_error(h(7), "At least one of the following conditions must be met", fixed = TRUE)
  expect_error(h("d"))
})

test_that("arg_or() and arg_and() respect a custom .msg", {
  f <- function(z) arg_or(z, arg_number, .msg = "custom failure")
  expect_identical(conditionMessage(rlang::catch_cnd(f("a"))), "Custom failure.")

  g <- function(z) arg_and(z, arg_number, .msg = "custom failure")
  expect_identical(conditionMessage(rlang::catch_cnd(g("a"))), "Custom failure.")
})

test_that("arg_or() propagates internal argument errors from malformed checks", {
  f <- function(z) arg_or(z, arg_length(len = "a"))
  expect_error(f(1))
})

test_that("arg_or() regroups a nested 'at least one of' failure message", {
  # arg_between() and arg_flag() share the "must be" prefix and get merged
  # into one combined bullet by the *nested* arg_or()'s own group_messages()
  # call, but arg_is()'s "must inherit from" message is left over as a
  # second, separate bullet -- so the nested arg_or() itself fails with a
  # genuine "At least one of the following conditions must be met:" message
  # (rather than being silently combined into a single string). Using that
  # nested call as the outer arg_or()'s *sole* check forces the outer call to
  # re-split the nested message's bullets via .split_bulleted_msg()
  # (R/arg_or.R's "at least one of" branch) and re-run group_messages() on
  # them. Since neither of the two bullets shares a prefix with the other at
  # this second pass, and there's nothing else to combine them with (this is
  # the outer arg_or()'s only check), both get swept into the single
  # leftover "or"-joined sentence rather than kept as separate bullets under
  # a header -- which is correct: an outer arg_or() with one nested check is
  # semantically just that check, so collapsing to one flowing sentence loses
  # no information.
  f <- function(z) {
    arg_or(z,
           arg_or(arg_is("nonexistent_class"),
                  arg_between(range = c(100, 200)),
                  arg_flag))
  }
  cnd <- rlang::catch_cnd(f(5))
  msg <- conditionMessage(cnd)
  expect_match(msg,
               "must be between 100 and 200 (inclusive) or a logical value (TRUE or FALSE) or must inherit from class",
               fixed = TRUE)
})

test_that("arg_or() surfaces only the internal argument error, not a mix of it and a prior check's user-facing failure", {
  # arg_string(1) fails first (a normal, user-facing failure) and is recorded
  # internally; arg_length(len = "a") then raises an internal_arg_error, which
  # should immediately replace the whole result, not be appended to or merged
  # with the already-recorded arg_string() failure message.
  f <- function(z) arg_or(z, arg_string, arg_length(len = "a"))
  cnd <- rlang::catch_cnd(f(1))
  msg <- conditionMessage(cnd)

  expect_match(msg, "must be a vector of counts", fixed = TRUE)
  expect_false(grepl("must be a string", msg, fixed = TRUE))
  expect_false(grepl("at least one of the following", msg, ignore.case = TRUE))
})

test_that("arg_and() propagates internal argument errors from malformed checks", {
  f <- function(z) arg_and(z, arg_number, arg_length(len = "a"))
  expect_error(f(1))
  expect_error(f("a"))
})

test_that("nested 'at least one of'/'all of' messages are re-split correctly under non-UTF-8 output (regression)", {
  # Regression test for a bug where R/arg_or.R's nested-message-regrouping
  # logic split on every entry in cli::symbol() (60+ symbols) instead of just
  # the tick/cross/bullet markers actually used. Under non-UTF-8 output (the
  # default in non-interactive R sessions, including testthat's own runner),
  # cli::symbol()'s ASCII fallbacks include plain single letters (tick = "v",
  # cross = "x"), which match constantly inside ordinary words -- e.g.
  # "non-negative" contains "v", so it used to get shredded into "non-negati"
  # + a garbled continuation. This reproduced even without any *passing*
  # nested check (i.e., independently of the separate make_fail() fix above),
  # via a plain nested arg_or()/arg_and() failure.
  rlang::local_options(cli.unicode = FALSE)

  h <- function(z) {
    arg_or(z,
           arg_is_NA,
           arg_and(arg_count, arg_lt(5)),
           arg_and(arg_string, arg_element(c("a", "b", "c"))))
  }
  cnd <- rlang::catch_cnd(h("d"))
  msg <- conditionMessage(cnd)
  expect_match(msg, "must be a count (a non-negative whole number) and comparable to 5 and be",
               fixed = TRUE)
  expect_match(msg, "less than 5", fixed = TRUE)
  expect_match(msg, "must be a string and one of \"a\", \"b\", or \"c\"", fixed = TRUE)

  g <- function(z) arg_and(z, arg_and(arg_number, arg_string), arg_flag)
  cnd2 <- rlang::catch_cnd(g(list()))
  msg2 <- conditionMessage(cnd2)
  expect_match(msg2, "must be a single number and `z` must be a string", fixed = TRUE)
})

test_that(".split_bulleted_msg() re-joins word-wrapped continuation lines into their bullet", {
  # Directly exercises the continuation-line branch, which depends on cli's
  # line-wrap position (and so isn't reliably hit by any single rendered
  # error message across environments/widths).
  msg <- paste(
    "All of the following conditions must be met:",
    paste0(cli::symbol$tick, " first bullet wraps onto a"),
    "  second physical line",
    paste0(cli::symbol$cross, " second bullet"),
    sep = "\n"
  )
  expect_identical(arg:::.split_bulleted_msg(msg),
                    c("first bullet wraps onto a second physical line", "second bullet"))
})
