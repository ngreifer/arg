test_that("arg_index() accepts a valid single column index or name for a data frame", {
  dat <- data.frame(col1 = 1:5, col2 = 6:10)
  f1 <- function(z) arg_index(z, dat)

  expect_null(f1(1))
  expect_null(f1("col1"))
  expect_error(f1(3), "must be the name or index of a column", fixed = TRUE)
  expect_error(f1("bad_col"))
  expect_error(f1(1:2), "must be the name or index of a column", fixed = TRUE)
})

test_that("arg_index() uses element phrasing for non-tabular data", {
  lis <- list(a = 1, b = 2)
  expect_null(arg_index(1, lis))
  expect_null(arg_index("a", lis))
  expect_error(arg_index("z", lis), "must be the name or index of an element", fixed = TRUE)

  lis2 <- list(1, 2)
  expect_error(arg_index("a", lis2), "must be the index of an element", fixed = TRUE)
})

test_that("arg_index() falls back to index-only phrasing when data has no names", {
  mat <- matrix(1:9, ncol = 3)
  f <- function(z) arg_index(z, mat)
  expect_error(f("col"), "must be the index of a column", fixed = TRUE)
})

test_that("arg_indices() accepts a vector of valid indices or names", {
  mat <- matrix(1:9, ncol = 3)
  g <- function(z) arg_indices(z, mat)

  expect_null(g(1))
  expect_null(g(1:3))
  expect_error(g("col"), "must be", fixed = TRUE)
  expect_error(g(4))
})

test_that("arg_name() requires a string that is a valid name and requires data to be named", {
  dat <- data.frame(col1 = 1:5, col2 = 6:10)
  f2 <- function(z) arg_name(z, dat)

  expect_null(f2("col1"))
  expect_error(f2(1), "must be the name of a column", fixed = TRUE)
  expect_error(f2("bad_col"))
  expect_error(f2(c("col1", "col2")), "must be the name of a column", fixed = TRUE)

  mat_unnamed <- matrix(1:9, ncol = 3)
  h <- function(z) arg_name(z, mat_unnamed)
  expect_error(h("a"))
})

test_that("arg_names() requires a character vector of valid names and requires data to be named", {
  dat <- data.frame(col1 = 1:5, col2 = 6:10)
  f3 <- function(z) arg_names(z, dat)

  expect_null(f3("col1"))
  expect_null(f3(c("col1", "col2")))
  expect_error(f3("bad_col"), "must be", fixed = TRUE)

  mat_unnamed <- matrix(1:9, ncol = 3)
  h2 <- function(z) arg_names(z, mat_unnamed)
  expect_error(h2("a"))
})

test_that("arg_index() family requires data to be supplied", {
  f4 <- function(z, d) arg_index(z, d)
  expect_error(f4(1))
})

test_that("arg_index() family respects a custom .msg", {
  dat <- data.frame(col1 = 1:5)
  expect_error(arg_index(99, dat, .msg = "custom failure"), "ustom failure", fixed = TRUE)
})
