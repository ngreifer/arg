test_that("arg_unique() errors only when there are duplicated values", {
  f <- function(z) arg_unique(z)
  expect_null(f(1:3))
  expect_null(f(NULL))
  expect_error(f(c(1, 1)), "must only contain unique values", fixed = TRUE)
  expect_error(f(c("a", "a", "b")))
})

test_that("arg_unique() passes ... through to anyDuplicated()", {
  expect_null(arg_unique(c(1, 1), incomparables = 1))
})

test_that("arg_unique() respects a custom .msg", {
  expect_error(arg_unique(c(1, 1), .msg = "custom failure"), "ustom failure", fixed = TRUE)
})
