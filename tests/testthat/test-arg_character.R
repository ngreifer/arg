test_that("arg_character() accepts character vectors and rejects other types", {
  expect_null(arg_character("a"))
  expect_null(arg_character(c("a", "b")))
  expect_null(arg_character(character()))
  expect_error(arg_character(1), "must be a character vector", fixed = TRUE)
  expect_error(arg_character(NULL))
  expect_error(arg_character(factor("a")))
})

test_that("arg_string() requires a non-NA character scalar", {
  expect_null(arg_string("a"))
  expect_error(arg_string(c("a", "b")), "must be a string", fixed = TRUE)
  expect_error(arg_string(NA), "must be a string", fixed = TRUE)
  expect_error(arg_string(character()))
  expect_error(arg_string(1))
})

test_that("arg_factor() checks for factor class", {
  expect_null(arg_factor(factor("a")))
  expect_error(arg_factor("a"), "must be a factor", fixed = TRUE)
  expect_error(arg_factor(1))
})

test_that("arg_character() family uses the caller's argument name and respects .msg", {
  f <- function(some_arg) arg_string(some_arg)
  expect_error(f(1), "`some_arg`", fixed = TRUE)
  expect_identical(conditionMessage(rlang::catch_cnd(arg_string(1, .msg = "custom failure"))),
                    "Custom failure.")
})

test_that("arg_character() respects a custom .msg", {
  expect_identical(conditionMessage(rlang::catch_cnd(arg_character(1, .msg = "custom character msg"))),
                    "Custom character msg.")
})

test_that("arg_string() gives an NA-specific message for a character NA scalar, and respects .msg", {
  expect_error(arg_string(NA_character_), "must not be", fixed = TRUE)
  expect_identical(conditionMessage(rlang::catch_cnd(arg_string(NA_character_, .msg = "custom na msg"))),
                    "Custom na msg.")
})

test_that("arg_factor() respects a custom .msg", {
  expect_identical(conditionMessage(rlang::catch_cnd(arg_factor("a", .msg = "custom factor msg"))),
                    "Custom factor msg.")
})

test_that("arg_ordered() checks for ordered factor class", {
  expect_null(arg_ordered(factor("a", ordered = TRUE)))
  expect_error(arg_ordered(factor("a")), "must be an ordered factor", fixed = TRUE)
  expect_error(arg_ordered("a"))
  expect_identical(conditionMessage(rlang::catch_cnd(arg_ordered(1, .msg = "custom ordered msg"))),
                    "Custom ordered msg.")
})
