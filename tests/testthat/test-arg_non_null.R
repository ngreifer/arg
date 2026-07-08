test_that("arg_non_null() errors on any length-0 object", {
  f <- function(x) arg_non_null(x)
  expect_null(f(1))
  expect_error(f(NULL), "must be non-NULL", fixed = TRUE)
  expect_error(f(numeric()))
  expect_error(f(list()))
  expect_error(f(c(1, 2)[c(FALSE, FALSE)]))
})

test_that("arg_null() errors on any non-length-0 object", {
  g <- function(y) arg_null(y)
  expect_null(g(NULL))
  expect_error(g(1), "must be NULL", fixed = TRUE)
})

test_that("arg_or() with arg_null() allows NULL as a valid alternative", {
  f2 <- function(z) arg_or(z, arg_null(), arg_number())
  expect_null(f2(NULL))
  expect_null(f2(1))
  expect_error(f2(TRUE))
})

test_that("arg_non_null() family respects a custom .msg", {
  expect_error(arg_non_null(NULL, .msg = "custom failure"), "ustom failure", fixed = TRUE)
})
