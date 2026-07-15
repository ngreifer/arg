test_that("arg_numeric() accepts any numeric vector", {
  expect_null(arg_numeric(c(0, .5, 1)))
  expect_null(arg_numeric(3L))
  expect_error(arg_numeric("3"), "must be a numeric vector", fixed = TRUE)
  expect_error(arg_numeric(NULL))
})

test_that("arg_number() requires a numeric scalar", {
  expect_null(arg_number(3))
  expect_null(arg_number(-4))
  expect_null(arg_number(.943))
  expect_error(arg_number(c(0, .5, 1)), "must be a single number", fixed = TRUE)
  expect_error(arg_number("3"), "must be a number", fixed = TRUE)
})

test_that("arg_whole_numeric() and arg_whole_number() check integerish values", {
  expect_null(arg_whole_numeric(c(3, -4, 0)))
  expect_error(arg_whole_numeric(c(3, .5)), "must be a whole numeric vector", fixed = TRUE)

  expect_null(arg_whole_number(3))
  expect_null(arg_whole_number(-4))
  expect_error(arg_whole_number(.943), "must be a whole number", fixed = TRUE)
  expect_error(arg_whole_number(c(3, 4)), "must be a single whole number", fixed = TRUE)
})

test_that("arg_counts() requires a vector of non-negative whole numbers", {
  expect_null(arg_counts(3))
  expect_null(arg_counts(c(0, 1, 2)))
  expect_error(arg_counts(-4), "must be a vector of counts", fixed = TRUE)
  expect_error(arg_counts(.943))
  expect_error(arg_counts(c(0, .5, 1)))
})

test_that("arg_count() requires a single non-negative whole number", {
  expect_null(arg_count(3))
  expect_error(arg_count(-4), "must be a count (a non-negative whole number)", fixed = TRUE)
  expect_error(arg_count(.943), "must be a count (a non-negative whole number)", fixed = TRUE)
  expect_error(arg_count(c(1, 2)), "must be a single count (a non-negative whole number)", fixed = TRUE)
})

test_that("arg_counts() and arg_count() do not crash on NA input and treat NA as integerish", {
  # Regression test: previously used any(x < 0), which errors with
  # "argument is not interpretable as logical" when x contains NA.
  expect_null(arg_counts(c(1L, NA)))
  expect_null(arg_count(NA_integer_))
  expect_error(arg_counts(c(-1L, NA)), "must be a vector of counts", fixed = TRUE)
})

test_that("arg_numeric() family respects a custom .msg", {
  expect_identical(conditionMessage(rlang::catch_cnd(arg_number("a", .msg = "custom failure"))),
                    "Custom failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_numeric("a", .msg = "custom numeric failure"))),
                    "Custom numeric failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_whole_numeric(.5, .msg = "custom whole_numeric failure"))),
                    "Custom whole_numeric failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_whole_number(.5, .msg = "custom whole_number failure"))),
                    "Custom whole_number failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_counts(-1, .msg = "custom counts failure"))),
                    "Custom counts failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_count(-1, .msg = "custom count failure"))),
                    "Custom count failure.")
})
