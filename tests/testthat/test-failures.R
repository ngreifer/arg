# These tests exercise the internal make_fail() helper (R/failures.R), used by
# arg_and() to synthesize a deliberately-failing call for each *passing* check
# so its message can be displayed alongside the failing checks. It is only
# reachable indirectly, through arg_and().

test_that("arg_and() shows a check mark for passing checks explicitly handled in make_fail()'s switch", {
  g <- function(z) arg_and(z, arg_counts, arg_length(len = 2), arg_lt(bound = 5))
  cnd <- rlang::catch_cnd(g(c(1, 7)))
  msg <- conditionMessage(cnd)
  expect_match(msg, "vector of counts", fixed = TRUE)
  expect_match(msg, "have length 2", fixed = TRUE)
})

test_that("arg_and() correctly marks a passing arg_named()/arg_colnamed() check", {
  obj <- c(A = 1, B = 2)
  g <- function(z) arg_and(z, arg_named, arg_length(len = 5))
  expect_error(g(obj), "must have length 5", fixed = TRUE)
})

test_that("arg_and() correctly falls back to a generic failing object for functions not explicitly listed in make_fail()'s switch", {
  # arg_flag(), arg_color(), and arg_function() have no dedicated case in
  # make_fail()'s switch statement; it substitutes a generic malformed object
  # (.evil_object) for x instead. This is verified here to still produce a
  # correct failing call (and hence a correct check mark) for these functions.
  g <- function(z) arg_and(z, arg_flag, arg_is("nonexistent_class"))
  cnd <- rlang::catch_cnd(g(TRUE))
  msg <- conditionMessage(cnd)
  expect_match(msg, "single logical value", fixed = TRUE)
  expect_match(msg, "inherit from class", fixed = TRUE)

  h <- function(z) arg_and(z, arg_color, arg_length(len = 5))
  cnd2 <- rlang::catch_cnd(h("red"))
  msg2 <- conditionMessage(cnd2)
  expect_match(msg2, "valid color", fixed = TRUE)
  expect_match(msg2, "have length 5", fixed = TRUE)

  k <- function(z) arg_and(z, arg_function, arg_is("nonexistent_class"))
  cnd3 <- rlang::catch_cnd(k(print))
  msg3 <- conditionMessage(cnd3)
  expect_match(msg3, "must be a function", fixed = TRUE)
})

test_that("arg_and() with a range-based check (arg_between family) reports failing bound correctly", {
  g <- function(z) arg_and(z, arg_counts, arg_lt(bound = 5))
  expect_error(g(7), "less than 5", fixed = TRUE)
})

test_that("arg_and() deduplicates identical failure messages across checks", {
  g <- function(z) arg_and(z, arg_number, arg_number)
  cnd <- rlang::catch_cnd(g("a"))
  msg <- conditionMessage(cnd)
  # The message should not repeat "must be a number" twice
  expect_identical(lengths(regmatches(msg, gregexpr("must be a number", msg))), 1L)
})

test_that("arg_and() with all checks passing returns invisibly with no error", {
  g <- function(z) arg_and(z, arg_number, arg_gt(0))
  expect_null(g(1))
})

test_that("make_fail() recurses into a passing nested arg_or() check that contains only checks without an 'x' formal", {
  # arg_dots_not_supplied()/arg_dots_supplied() are the only check functions
  # with no "x" formal. arg_dots_not_supplied() always passes trivially (its
  # "..." is never forwarded), so this nested arg_or() always succeeds
  # regardless of z, letting arg_string below be the one and only failure;
  # make_fail() is then invoked on the whole passing arg_or() call, exercising
  # its arg_and()/arg_or() recursion branch.
  f <- function(z) {
    arg_and(z,
            arg_or(arg_dots_not_supplied, arg_dots_supplied),
            arg_string)
  }
  expect_error(f(5), "must be a string", fixed = TRUE)
})

test_that("make_fail() recurses into a passing nested arg_and()/arg_or() check whose sub-checks have an 'x' formal", {
  # Regression test for a bug where make_fail()'s recursion branch called
  # .to_arg_fun_call(j) with only one argument, omitting the required
  # x_name/.arg parameters. This threw "argument \"x_name\" is missing" for
  # any nested check with an "x" formal (i.e., anything besides the
  # dots-related checks covered above).
  #
  # Only arg_and() calls make_fail() (to synthesize a message for a *passing*
  # check), so the nested check must itself be a passing arg_or()/arg_and()
  # embedded inside an outer arg_and() that also has a genuinely failing
  # check. Here, arg_or(arg_number, arg_string) passes for z = 5 (5 is a
  # number), while arg_length(len = 2) fails (z has length 1), so make_fail()
  # must recurse into the passing arg_or() call without erroring, and its
  # tick-mark message should be included alongside the arg_length() failure.
  f <- function(z) {
    arg_and(z,
            arg_or(arg_number, arg_string),
            arg_length(len = 2))
  }
  cnd <- rlang::catch_cnd(f(5))
  msg <- conditionMessage(cnd)
  expect_match(msg, "All of the following conditions must be met", fixed = TRUE)
  expect_match(msg, paste0(cli::symbol$tick, " `z` must be a single number or a string"), fixed = TRUE)
  expect_match(msg, paste0(cli::symbol$cross, " `z` must have length 2"), fixed = TRUE)
})

test_that("make_fail() preserves a passing nested arg_and() check's tick-mark message (not just arg_or())", {
  # This scenario's nested arg_and() check produces its own compound "All of
  # the following..." sub-message, which the outer arg_and() re-splits using
  # every entry in cli::symbol() as a delimiter (R/arg_or.R's nested-message
  # regrouping logic). Under non-UTF-8 output, cli::symbol()'s ASCII fallbacks
  # include plain single letters (e.g. tick = "v", info = "i"), which match
  # constantly inside ordinary English words and garble the message -- a
  # separate, pre-existing bug unrelated to this fix (reproducible even
  # without any passing nested check, e.g. via a nested arg_and() that fails
  # outright). Forcing UTF-8 symbols here isolates this test to what this fix
  # is actually responsible for.
  rlang::local_options(cli.unicode = TRUE)

  f <- function(z) {
    arg_and(z,
            arg_and(arg_number, arg_lt(10)),
            arg_length(len = 2))
  }
  cnd <- rlang::catch_cnd(f(5))
  msg <- conditionMessage(cnd)
  expect_match(msg, "All of the following conditions must be met", fixed = TRUE)
  expect_match(msg,
               paste0(cli::symbol$tick,
                      " `z` must be a single number and each element of `z` must be less than 10"),
               fixed = TRUE)
  expect_match(msg, paste0(cli::symbol$cross, " `z` must have length 2"), fixed = TRUE)
})

test_that("a passing nested check's tick-mark message survives alongside multiple failing checks", {
  f <- function(z) {
    arg_and(z,
            arg_or(arg_number, arg_string),
            arg_length(len = 2),
            arg_lt(bound = 2))
  }
  cnd <- rlang::catch_cnd(f(5))
  msg <- conditionMessage(cnd)
  expect_match(msg, paste0(cli::symbol$tick, " `z` must be a single number or a string"), fixed = TRUE)
  expect_match(msg, paste0(cli::symbol$cross, " `z` must have length 2"), fixed = TRUE)
  expect_match(msg, paste0(cli::symbol$cross, " `z` must be less than 2"), fixed = TRUE)
})

test_that("make_fail() covers each remaining switch branch via a directly-passing check", {
  # Each of these check functions has an "x" formal.
  expect_error(arg_and(5, arg_element(values = c(1, 2, 3)), arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(5, arg_element(values = c(NA, 1, 2)), arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(5, arg_equal(x2 = 5), arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(NaN, arg_equal(x2 = NaN), arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(1, arg_index(data = list(a = 1)), arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(1, arg_indices(data = list(a = 1)), arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(5, arg_is_not("nonexistent_xyz"), arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(1, arg_no_NA, arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(1, arg_non_null, arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(5, arg_not_element(values = c(999)), arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(5, arg_not_equal(x2 = 999), arg_string),
               "must be a string", fixed = TRUE)
  expect_error(arg_and(5, arg_supplied, arg_string),
               "must be a string", fixed = TRUE)
})

test_that("arg_and() regroups a nested 'at least one of' failure message alongside a plain failure", {
  # arg_between() and arg_string() share the "must be" prefix and get merged
  # by the nested arg_or()'s own grouping, leaving arg_is()'s "must inherit
  # from" message as a separate bullet, so the nested arg_or() itself fails
  # with a genuine "At least one of the following conditions must be met:"
  # message.
  f <- function(z) {
    arg_and(z,
            arg_or(arg_is("nonexistent_class"),
                   arg_between(range = c(100, 200)),
                   arg_string),
            arg_flag)
  }
  cnd <- rlang::catch_cnd(f(5))
  msg <- conditionMessage(cnd)
  expect_match(msg, "All of the following conditions must be met", fixed = TRUE)
})

test_that("arg_and() regroups a nested 'all of' failure message alongside a plain failure", {
  f <- function(z) {
    arg_and(z,
            arg_and(arg_number, arg_string),
            arg_flag)
  }
  cnd <- rlang::catch_cnd(f(list()))
  msg <- conditionMessage(cnd)
  expect_match(msg, "All of the following conditions must be met", fixed = TRUE)
})
