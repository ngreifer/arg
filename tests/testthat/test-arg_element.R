test_that("arg_element() accepts values in the set, without partial matching", {
  f <- function(z) arg_element(z, c("opt1", "opt2", "opt3"))
  expect_null(f("opt1"))
  expect_null(f(c("opt1", "opt2")))
  expect_null(f(c("opt1", "opt1")))
  expect_error(f("bad_arg"), 'must be one of "opt1", "opt2", or "opt3"', fixed = TRUE)
  expect_error(f("opt"), "must be one of", fixed = TRUE)
  expect_error(f(c("opt1", "bad_arg")),
               'Each element of `z` must be one of "opt1", "opt2", or "opt3"', fixed = TRUE)
})

test_that("arg_element() errors informatively for NULL x or values", {
  expect_error(arg_element(NULL, c("a", "b")), "must be one of", fixed = TRUE)
  expect_error(arg_element("a", NULL), "cannot take on any value", fixed = TRUE)
})

test_that("arg_element() has a special message for an empty-string-only set", {
  f <- function(z) arg_element(z, "")
  expect_error(f("a"), 'must be the empty string', fixed = TRUE)
  expect_null(f(""))

  g <- function(z) arg_element(z, "")
  expect_error(g(c("a", "b")), 'Each element of `z` must be the empty string', fixed = TRUE)
})

test_that("arg_not_element() errors when any value is in the excluded set", {
  g <- function(z) arg_not_element(z, c("bad1", "bad2", "bad3"))
  expect_null(g("opt1"))
  expect_null(g(c("opt1", "opt2")))
  expect_error(g("bad1"), 'must not be "bad1", "bad2", or "bad3"', fixed = TRUE)
  expect_error(g(c("bad1", "opt2")),
               'No element of `z` may be "bad1", "bad2", or "bad3"', fixed = TRUE)
})

test_that("arg_not_element() has a special message for an excluded empty string", {
  g <- function(z) arg_not_element(z, "")
  expect_error(g(""), "must not be the empty string", fixed = TRUE)
  expect_null(g("a"))

  g2 <- function(z) arg_not_element(z, "")
  expect_error(g2(c("", "a")), "No element of `z` may be the empty string", fixed = TRUE)
})

test_that("arg_not_element() is a no-op for NULL x", {
  expect_null(arg_not_element(NULL, c("a", "b")))
})

test_that("arg_element() family respects a custom .msg", {
  f <- function(z) arg_element(z, c("a", "b"), .msg = "custom failure")
  expect_identical(conditionMessage(rlang::catch_cnd(f("c"))), "Custom failure.")

  g <- function(z) arg_not_element(z, c("a", "b"), .msg = "custom not-element failure")
  expect_identical(conditionMessage(rlang::catch_cnd(g("a"))), "Custom not-element failure.")
})
