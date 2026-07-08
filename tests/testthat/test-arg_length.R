test_that("arg_length() accepts a matching length and errors otherwise", {
  obj <- 1:4
  expect_null(arg_length(obj, 4))
  expect_null(arg_length(obj, c(1, 4)))
  expect_null(arg_length(obj, 0:4))
  expect_error(arg_length(obj, 1), "must have length 1", fixed = TRUE)
})

test_that("arg_length() reports multiple allowed lengths in the error message", {
  obj <- 1:4
  expect_error(arg_length(obj, 0:3), "must have length 0, 1, 2, or 3", fixed = TRUE)
})

test_that("arg_length() validates its len argument as counts", {
  expect_error(arg_length(1, "a"))
  expect_error(arg_length(1, -1))
})

test_that("arg_length() respects a custom .msg", {
  expect_error(arg_length(1:4, 1, .msg = "custom failure"), "ustom failure", fixed = TRUE)
})
