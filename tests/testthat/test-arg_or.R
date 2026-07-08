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
  expect_match(msg, "vector of counts", fixed = TRUE)
  expect_match(msg, "have length 2", fixed = TRUE)
  expect_match(msg, "less than 5", fixed = TRUE)
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
  expect_error(f("a"), "ustom failure", fixed = TRUE)

  g <- function(z) arg_and(z, arg_number, .msg = "custom failure")
  expect_error(g("a"), "ustom failure", fixed = TRUE)
})

test_that("arg_or() propagates internal argument errors from malformed checks", {
  f <- function(z) arg_or(z, arg_length(len = "a"))
  expect_error(f(1))
})
