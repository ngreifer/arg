test_that("arg_dots_supplied() errors only when ... is empty", {
  f <- function(...) arg_dots_supplied(...)
  expect_null(f(1))
  expect_null(f(1, 2))
  expect_error(f(), "An argument must be supplied to `...`", fixed = TRUE)
})

test_that("arg_dots_not_supplied() errors only when ... is non-empty", {
  g <- function(...) arg_dots_not_supplied(...)
  expect_null(g())
  expect_error(g(1), "No arguments may be supplied to `...`", fixed = TRUE)
  expect_error(g(1, 2))
})

test_that("arguments passed to ... are not evaluated", {
  f <- function(...) arg_dots_supplied(...)
  expect_null(f(stop("should not be evaluated")))
})

test_that("arg_dots_supplied() family respects a custom .msg", {
  f <- function(...) arg_dots_supplied(..., .msg = "custom failure")
  expect_identical(conditionMessage(rlang::catch_cnd(f())), "Custom failure.")

  g <- function(...) arg_dots_not_supplied(..., .msg = "custom not-supplied failure")
  expect_identical(conditionMessage(rlang::catch_cnd(g(1))), "Custom not-supplied failure.")
})
