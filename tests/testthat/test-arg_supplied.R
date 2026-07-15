test_that("arg_supplied() errors only when a no-default argument is omitted", {
  f <- function(z) arg_supplied(z)
  expect_null(f(1))
  expect_error(f(), "An argument to `z` must be supplied", fixed = TRUE)
})

test_that("arg_supplied() does not error for NULL or defaulted arguments", {
  f <- function(z) arg_supplied(z)
  expect_null(f(NULL))

  f2 <- function(z = NULL) arg_supplied(z)
  expect_null(f2())
})

test_that("arg_supplied() respects a custom .msg", {
  f <- function(z) arg_supplied(z, .msg = "custom failure")
  expect_identical(conditionMessage(rlang::catch_cnd(f())), "Custom failure.")
})

test_that("arg_supplied() throws an internal error when x's expression is not a symbol", {
  expect_error(arg_supplied(rlang::missing_arg()))
})
