test_that("match_arg() returns the first choice when x is NULL", {
  f <- function(z = NULL) match_arg(z, c("None", "Exact", "Partial"))
  expect_identical(f(), "None")
})

test_that("match_arg() supports exact and partial matching", {
  f <- function(z = NULL) match_arg(z, c("None", "Exact", "Partial"), ignore.case = TRUE)
  expect_identical(f("partial"), "Partial")
  expect_identical(f("p"), "Partial")
  expect_identical(f("Exact"), "Exact")
})

test_that("match_arg() errors when several.ok = FALSE and multiple values are supplied", {
  f <- function(z = NULL) match_arg(z, c("None", "Exact", "Partial"), ignore.case = TRUE)
  expect_error(f(c("e", "p")), "must be a string", fixed = TRUE)
})

test_that("match_arg() is case-sensitive first, then falls back to case-insensitive by default", {
  g <- function(z = NULL) match_arg(z, c("None", "Exact", "Partial", "exact"), several.ok = TRUE)
  expect_identical(g("exact"), "exact")
  expect_identical(g("Exact"), "Exact")
})

test_that("match_arg() with ignore.case = FALSE only performs a case-sensitive match", {
  g2 <- function(z = NULL) {
    match_arg(z, c("None", "Exact", "Partial"), several.ok = TRUE, ignore.case = FALSE)
  }
  expect_error(g2("exact"), "should be at least one of", fixed = TRUE)
  expect_identical(g2("Exact"), "Exact")
})

test_that("match_arg() with several.ok = TRUE matches and returns multiple values", {
  g <- function(z = NULL) match_arg(z, c("None", "Exact", "Partial"), several.ok = TRUE)
  expect_identical(g(c("Exact", "Partial")), c("Exact", "Partial"))
  expect_identical(g(c("Exact", "Wrong")), "Exact")
  expect_error(g(c("Wrong1", "Wrong2")), "should be at least one of", fixed = TRUE)
})

test_that("match_arg() prepends .context to the error message when supplied", {
  h <- function(z = NULL) match_arg(z, c("None", "Exact", "Partial"), .context = "in {.fun h},")
  expect_error(h("Wrong"), "In `h()`, `z` should be one of", fixed = TRUE)
})

test_that("match_arg() requires choices to be a supplied character vector", {
  f <- function(z, ch) match_arg(z, ch)
  expect_error(f("a"))
  expect_error(match_arg("a", 1:3))
})

test_that("match_arg() requires x to be supplied (no default)", {
  f <- function(z) match_arg(z, c("a", "b"))
  expect_error(f())
})

test_that("match_arg() deduplicates choices", {
  f <- function(z = NULL) match_arg(z, c("a", "a", "b"))
  expect_identical(f(), "a")
})
