test_that("arg_between() accepts values within the default and custom range", {
  expect_null(arg_between(0.5))
  expect_null(arg_between(0))
  expect_null(arg_between(1))
  expect_null(arg_between(2, c(1, 3)))
  expect_null(arg_between(2, c(1, 2)))
})

test_that("arg_between() rejects values outside the range", {
  z <- 2
  expect_error(arg_between(z, c(1, 2), inclusive = FALSE),
               "`z` must be between 1 and 2 (exclusive)", fixed = TRUE)
  expect_error(arg_between(5, c(1, 2)),
               "must be between 1 and 2", fixed = TRUE)
})

test_that("arg_between() supports asymmetric inclusive bounds", {
  z <- 2
  expect_error(arg_between(z, c(1, 2), inclusive = c(TRUE, FALSE)),
               "`z` must be greater than or equal to 1 and less than 2", fixed = TRUE)
  expect_null(arg_between(1, c(1, 2), inclusive = c(TRUE, FALSE)))
  expect_error(arg_between(2, c(1, 2), inclusive = c(TRUE, FALSE)))
})

test_that("arg_between() reorders an unsorted range", {
  expect_null(arg_between(2, c(3, 1)))
  expect_error(arg_between(5, c(3, 1)),
               "must be between 1 and 3", fixed = TRUE)
})

test_that("arg_between() validates its own arguments", {
  expect_error(arg_between(1, range = 1))
  expect_error(arg_between(1, inclusive = "yes"))
  expect_error(arg_between(1, inclusive = c(TRUE, FALSE, TRUE)))
})

test_that("arg_between() errors when x and range/bound are not comparable types", {
  expect_error(arg_between("a", c(1, 2)))
  expect_error(arg_lte(2, "3"))
})

test_that("arg_between() vectorizes with 'each element of' phrasing", {
  expect_null(arg_between(c(0.2, 0.5, 0.8)))
  expect_error(arg_between(c(0.2, 1.5)),
               "Each element of", fixed = TRUE)
})

test_that("arg_between() errors on NA values (not silently dropped)", {
  expect_error(arg_between(NA))
  expect_error(arg_between(c(0.5, NA)))
})

test_that("arg_gt() checks strictly-greater-than, with 'positive' shorthand at bound 0", {
  expect_null(arg_gt(1))
  expect_error(arg_gt(0), "must be positive", fixed = TRUE)
  expect_error(arg_gt(2, 2), "must be greater than 2", fixed = TRUE)
  expect_null(arg_gt(3, 2))
  expect_error(arg_gt(c(1, 2, -1), 0),
               "Each element of `c(1, 2, -1)` must be positive", fixed = TRUE)
})

test_that("arg_gte() checks greater-than-or-equal", {
  expect_null(arg_gte(2, 2))
  expect_error(arg_gte(1, 2),
               "must be greater than or equal to 2", fixed = TRUE)
})

test_that("arg_lt() checks strictly-less-than, with 'negative' shorthand at bound 0", {
  expect_null(arg_lt(-1))
  expect_error(arg_lt(0), "must be negative", fixed = TRUE)
  expect_error(arg_lt(2, 2), "must be less than 2", fixed = TRUE)
})

test_that("arg_lte() checks less-than-or-equal", {
  expect_null(arg_lte(2, 2))
  expect_error(arg_lte(3, 2),
               "must be less than or equal to 2", fixed = TRUE)
})

test_that("arg_gt()/arg_gte()/arg_lt()/arg_lte() validate the bound argument", {
  expect_error(arg_gt(1, bound = c(1, 2)))
  expect_error(arg_lte(1, bound = c(1, 2)))
})

test_that("arg_between() family uses the caller's argument name by default", {
  f <- function(some_arg) arg_gt(some_arg, 0)
  expect_error(f(-1), "`some_arg`", fixed = TRUE)
})

test_that("arg_between() family respects a custom .msg", {
  expect_error(arg_gt(-1, .msg = "custom failure message"),
               "ustom failure message", fixed = TRUE)
})
