test_that("err() throws an error with a capitalized, period-terminated message", {
  f <- function(x) err("this is an error, and {.arg x} is {.type {x}}")
  expect_error(f(1), "This is an error, and `x` is a number.", fixed = TRUE)
})

test_that("err() does not add a period if the message already ends in punctuation", {
  f <- function() err("already punctuated!")
  expect_error(f(), "Already punctuated!", fixed = TRUE)
})

test_that("err() does not capitalize or add punctuation to multi-element (bulleted) messages", {
  f <- function() err(c("first line", "!" = "second line"))
  cnd <- rlang::catch_cnd(f())
  expect_match(conditionMessage(cnd), "first line", fixed = TRUE)
  expect_match(conditionMessage(cnd), "second line", fixed = TRUE)
})

test_that("err() accepts .call = NULL to omit call information", {
  f <- function(x) err("boom", .call = NULL)
  cnd <- rlang::catch_cnd(f(1))
  expect_null(conditionCall(cnd))
})

test_that("err() validates that .envir is an environment", {
  expect_error(err("boom", .envir = 1), "must be an environment", fixed = TRUE)
})

test_that("err() evaluates cli glue syntax in the message using .envir", {
  f <- function(x) err("value is {x}", .envir = environment())
  expect_error(f(42), "Value is 42", fixed = TRUE)
})

test_that("wrn() throws a warning and invisibly returns the formatted message", {
  g <- function(x) wrn("this is a warning")
  w <- expect_warning(g(1), "This is a warning.", fixed = TRUE)
  expect_true(inherits(w, "warning"))

  r <- withCallingHandlers(
    wrn("returns this"),
    warning = function(w) invokeRestart("muffleWarning")
  )
  expect_identical(r, "Returns this.")
})

test_that("wrn() validates the immediate argument as a flag", {
  expect_error(wrn("x", immediate = "yes"))
  expect_error(wrn("x", immediate = c(TRUE, FALSE)))
})

test_that("msg() signals a message and invisibly returns NULL", {
  h <- function() msg("is a period added at the end?")
  expect_message(h(), "Is a period added at the end?", fixed = TRUE)

  r <- suppressMessages(msg("hello"))
  expect_null(r)
})

test_that("msg() does not add a period when the message ends in punctuation", {
  h2 <- function() msg("not when the message ends in punctuation!")
  expect_message(h2(), "Not when the message ends in punctuation!", fixed = TRUE)
})

test_that(".pkg_caller_call() correctly walks a stack containing a global-environment frame", {
  # Defining (not just assigning) the wrapper with envir = globalenv() makes
  # its closure environment identical to globalenv(), exercising the
  # globalenv-skip branch inside .pkg_caller_call()'s stack walk.
  eval(quote(.test_err_wrapper_global <- function(x) arg_gt(x, 0)), envir = globalenv())
  on.exit(rm(".test_err_wrapper_global", envir = globalenv()))

  cnd <- rlang::catch_cnd(.test_err_wrapper_global(-1))
  expect_true(inherits(cnd, "error"))
  expect_match(conditionMessage(cnd), "must be positive", fixed = TRUE)
})
