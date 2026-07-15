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
  expect_identical(conditionMessage(rlang::catch_cnd(arg_index(99, dat, .msg = "custom failure"))),
                    "Custom failure.")
})

test_that("arg_indices() uses element phrasing for non-tabular data and respects .msg", {
  lis <- list(a = 1, b = 2, c = 3)
  g2 <- function(z) arg_indices(z, lis)

  expect_null(g2(1))
  expect_null(g2(1:2))
  expect_null(g2("a"))
  expect_null(g2(c("a", "b")))
  expect_error(g2("z"), "must be", fixed = TRUE)
  expect_error(g2(c("a", "z")), "must be", fixed = TRUE)
  expect_error(g2(5), "must be", fixed = TRUE)

  lis2 <- list(1, 2, 3)
  expect_error(arg_indices("a", lis2), "must be", fixed = TRUE)

  expect_identical(conditionMessage(rlang::catch_cnd(arg_indices(99, lis, .msg = "custom indices failure"))),
                    "Custom indices failure.")
})

test_that("arg_indices() reports column-name phrasing when colnames exist but index is invalid", {
  dat <- data.frame(col1 = 1:5, col2 = 6:10)
  g3 <- function(z) arg_indices(z, dat)
  expect_error(g3("bad_col"), "must be", fixed = TRUE)
  expect_error(g3(c("col1", "bad_col")), "must be", fixed = TRUE)
})

test_that("arg_name() works for non-tabular (named-vector/list) data and respects .msg", {
  lis <- list(a = 1, b = 2)
  f5 <- function(z) arg_name(z, lis)
  expect_null(f5("a"))
  expect_error(f5("z"), "must be the name of an element", fixed = TRUE)
  expect_error(f5(c("a", "b")), "must be the name of an element", fixed = TRUE)

  expect_identical(conditionMessage(rlang::catch_cnd(arg_name("z", lis, .msg = "custom name failure"))),
                    "Custom name failure.")
})

test_that("arg_names() works for non-tabular (named-vector/list) data and respects .msg", {
  lis <- list(a = 1, b = 2)
  f6 <- function(z) arg_names(z, lis)
  expect_null(f6("a"))
  expect_null(f6(c("a", "b")))
  expect_error(f6("z"), "must be", fixed = TRUE)

  dat <- data.frame(col1 = 1:5, col2 = 6:10)
  f7 <- function(z) arg_names(z, dat)
  expect_error(f7(c("col1", "bad_col")), "must be", fixed = TRUE)

  expect_identical(conditionMessage(rlang::catch_cnd(arg_names("z", lis, .msg = "custom names failure"))),
                    "Custom names failure.")
})
