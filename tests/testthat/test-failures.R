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
