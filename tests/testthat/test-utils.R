# These tests exercise internal (non-exported) helper functions from R/utils.R.

test_that("is_null() and is_not_null() test for length-0 objects", {
  expect_true(is_null(NULL))
  expect_true(is_null(numeric()))
  expect_true(is_null(list()))
  expect_false(is_null(1))
  expect_false(is_null(NA))

  expect_false(is_not_null(NULL))
  expect_true(is_not_null(1))
})

test_that("is_scalar() tests for length-1 objects", {
  expect_true(is_scalar(1))
  expect_true(is_scalar(NA))
  expect_true(is_scalar("a"))
  expect_false(is_scalar(c(1, 2)))
  expect_false(is_scalar(NULL))
})

test_that("is_color() validates color specifications via col2rgb()", {
  expect_true(is_color("red"))
  expect_true(is_color("#A4A473"))
  expect_true(is_color(15))
  expect_false(is_color("not_a_color"))
  expect_false(is_color(-15))
  expect_false(is_color(list("not_a_color")))
})

test_that("check_if_zero() uses all.equal()'s default tolerance", {
  expect_true(check_if_zero(0))
  expect_true(check_if_zero(1e-10))
  expect_false(check_if_zero(0.1))
})

test_that("safe_any() and safe_all() treat NA as FALSE instead of erroring", {
  expect_false(safe_any(c(FALSE, NA)))
  expect_true(safe_any(c(FALSE, NA, TRUE)))
  expect_false(safe_all(c(TRUE, NA)))
  expect_true(safe_all(c(TRUE, TRUE)))
})

test_that("safe_any()/safe_all() do not error on comparisons that produce NA", {
  x <- c(1L, NA)
  expect_false(safe_any(x < 0))
  expect_false(safe_all(x < 0))
  expect_true(safe_any(c(-1L, NA) < 0))
})

test_that("ansi_trim() trims a fixed number of characters from each side", {
  expect_identical(as.character(ansi_trim("hello", left = 1, right = 1)), "ell")
  expect_identical(as.character(ansi_trim("hello", left = 2)), "llo")
  expect_identical(as.character(ansi_trim("hello", right = 2)), "hel")
})

test_that("ansi_upper_first() capitalizes only the first alphabetic character", {
  expect_identical(ansi_upper_first("hello"), "Hello")
  expect_identical(ansi_upper_first("h"), "H")
  expect_identical(ansi_upper_first("`x` is bad"), "`x` is bad")
  expect_identical(ansi_upper_first(c("one", "two")), c("One", "Two"))
})

test_that("ansi_lower_first() lowercases only the first alphabetic character", {
  expect_identical(ansi_lower_first("Hello"), "hello")
  expect_identical(ansi_lower_first("H"), "h")
  expect_identical(ansi_lower_first("`X` is bad"), "`X` is bad")
})

test_that("trim_final_punct() removes a single trailing period, question mark, or exclamation point", {
  expect_identical(trim_final_punct("done."), "done")
  expect_identical(trim_final_punct("really?"), "really")
  expect_identical(trim_final_punct("wow!"), "wow")
  expect_identical(trim_final_punct("no change"), "no change")
})

test_that("any_apply() and all_apply() short-circuit like any()/all() over elements of X", {
  expect_true(any_apply(1:5, function(x) x == 3))
  expect_false(any_apply(1:5, function(x) x == 10))
  expect_true(all_apply(1:5, function(x) x > 0))
  expect_false(all_apply(1:5, function(x) x > 3))
})

test_that("any_apply() and all_apply() coerce vector-like objects with a class to a list first", {
  df <- data.frame(a = 1:3, b = 4:6)
  expect_true(any_apply(df, is.numeric))
  expect_true(all_apply(df, is.numeric))
})

test_that("internal_arg() re-signals errors with an added internal_arg_error class", {
  cnd <- rlang::catch_cnd(internal_arg(stop("boom")))
  expect_true(inherits(cnd, "internal_arg_error"))
  expect_true(inherits(cnd, "error"))
})

test_that("internal_arg() passes through successful evaluation unchanged", {
  expect_identical(internal_arg(1 + 1), 2)
})

test_that(".msg_eval() validates that .msg is NULL or a character vector", {
  expect_identical(.msg_eval("a message"), "a message")
  expect_identical(.msg_eval(NULL), NULL)
  expect_error(.msg_eval(1))
})
