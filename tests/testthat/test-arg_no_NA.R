test_that("arg_no_NA() errors when x contains any NA", {
  f <- function(x) arg_no_NA(x)
  expect_null(f(1))
  expect_error(f(NA), "must not be NA", fixed = TRUE)
  expect_error(f(c(1, NA, 3)), "must not contain NA values", fixed = TRUE)
})

test_that("arg_all_NA() errors unless every element is NA", {
  f2 <- function(y) arg_all_NA(y)
  expect_null(f2(NA))
  expect_null(f2(c(NA, NA)))
  expect_error(f2(1), "must only contain NA values", fixed = TRUE)
  expect_error(f2(c(1, NA, 3)))
})

test_that("arg_is_NA() requires a scalar, atomic NA", {
  expect_null(arg_is_NA(NA))
  expect_null(arg_is_NA(NA_character_))
  expect_error(arg_is_NA(c(NA, NA)), "must be NA", fixed = TRUE)
  expect_error(arg_is_NA(1), "must be NA", fixed = TRUE)
  expect_error(arg_is_NA(list(NA)))
})

test_that("arg_no_NA() family respects a custom .msg", {
  expect_error(arg_no_NA(NA, .msg = "custom failure"), "ustom failure", fixed = TRUE)
})
