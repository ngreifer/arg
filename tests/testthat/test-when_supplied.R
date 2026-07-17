test_that("when_supplied() only checks x if it was supplied", {
  f <- function(z) when_supplied(z, arg_number, arg_between(c(0, 1)))
  expect_null(f())
  expect_error(f("a"), "When `z` is supplied, `z` must be a number", fixed = TRUE)
  expect_error(f(2), "When `z` is supplied, `z` must be between 0 and 1 (inclusive)", fixed = TRUE)
  expect_null(f(.7))
})

test_that("when_not_null() only checks x if it is not NULL", {
  g <- function(z = NULL) when_not_null(z, arg_number, arg_between(c(0, 1)))
  expect_null(g())
  expect_null(g(NULL))
  expect_error(g("a"), "When `z` is not NULL, `z` must be a number", fixed = TRUE)
  expect_error(g(2), "When `z` is not NULL, `z` must be between 0 and 1 (inclusive)", fixed = TRUE)
  expect_null(g(.7))
})

test_that("when_supplied() and when_not_null() accept unevaluated call syntax", {
  f <- function(z) when_supplied(z, arg_number(), arg_gt(bound = 0))
  expect_null(f(1))
  expect_error(f(-1))

  g <- function(z = NULL) when_not_null(z, arg_number(), arg_gt(bound = 0))
  expect_null(g())
  expect_error(g(-1))
})

test_that("when_supplied() and when_not_null() require at least one check", {
  f <- function(z) when_supplied(z)
  expect_error(f(1))

  g <- function(z = NULL) when_not_null(z)
  expect_error(g(1))
})

test_that("when_supplied() stops at the first failing check", {
  f <- function(z) when_supplied(z, arg_number, arg_gt(bound = 0))
  expect_error(f("a"), "must be a number", fixed = TRUE)
})

test_that("when_supplied() and when_not_null() propagate an internal error raised by a check", {
  f <- function(z) when_supplied(z, arg_between(inclusive = "bad"))
  expect_error(f(1))

  g <- function(z = NULL) when_not_null(z, arg_between(inclusive = "bad"))
  expect_error(g(1))
})

test_that("when_supplied()/when_not_null() preserve the indented cascade of a nested compound check", {
  withr::local_options(cli.unicode = TRUE, cli.num_colors = 1, width = 200)
  tick <- cli::symbol$tick
  cross <- cli::symbol$cross
  bull <- cli::symbol$bullet

  f <- function(z) when_supplied(z, arg_or(arg_and(arg_all_NA, arg_length(1L)),
                                           arg_and(arg_no_NA, arg_length(2L))))
  msg <- conditionMessage(rlang::catch_cnd(f(1)))

  expected <- paste(
    "When `z` is supplied, at least one of the following conditions must be met:",
    paste0(bull, " All of the following conditions must be met:"),
    paste0("  ", cross, " `z` must only contain NA values"),
    paste0("  ", tick, " `z` must have length 1"),
    paste0(bull, " All of the following conditions must be met:"),
    paste0("  ", tick, " `z` must not contain NA values"),
    paste0("  ", cross, " `z` must have length 2"),
    sep = "\n"
  )
  expect_identical(msg, expected)

  g <- function(z = NULL) when_not_null(z, arg_or(arg_and(arg_all_NA, arg_length(1L)),
                                                  arg_and(arg_no_NA, arg_length(2L))))
  msg2 <- conditionMessage(rlang::catch_cnd(g(1)))
  expect_match(msg2, "When `z` is not NULL, at least one of the following conditions must be met:",
               fixed = TRUE)
  expect_match(msg2, paste0("  ", cross, " `z` must only contain NA values"), fixed = TRUE)
})
