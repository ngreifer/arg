test_that("arg_equal() uses all.equal() semantics, ignoring type differences and applying tolerance", {
  f <- function(x, y, ...) arg_equal(x, y, ...)
  expect_null(f(x = 1, y = 1))
  expect_null(f(x = 1L, y = 1.0))
  expect_null(f(x = 1, y = 1.00001, tolerance = .001))
  expect_error(f(x = 1, y = 2), "`x` must be equal to `y`", fixed = TRUE)
  expect_error(f(x = 1, y = 1.00001))
})

test_that("arg_not_equal() errors only when the objects are equal", {
  g <- function(x, y, ...) arg_not_equal(x, y, ...)
  expect_error(g(x = 1, y = 1), "`x` must not be equal to `y`", fixed = TRUE)
  expect_null(g(x = 1, y = 2))
})

test_that("arg_equal() and arg_not_equal() require x2 to be supplied", {
  f <- function(x, y) arg_equal(x, y)
  expect_error(f(1))
})

test_that("arg_equal() family respects a custom .msg", {
  f <- function(x, y) arg_equal(x, y, .msg = "custom failure")
  expect_identical(conditionMessage(rlang::catch_cnd(f(1, 2))), "Custom failure.")

  g <- function(x, y) arg_not_equal(x, y, .msg = "custom not-equal failure")
  expect_identical(conditionMessage(rlang::catch_cnd(g(1, 1))), "Custom not-equal failure.")
})
