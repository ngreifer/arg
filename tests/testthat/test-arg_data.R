test_that("arg_atomic() accepts atomic vectors (including matrices and data frames) and rejects lists", {
  vec <- 1:6
  mat <- as.matrix(vec)
  dat <- as.data.frame(mat)
  lis <- as.list(vec)

  expect_null(arg_atomic(vec))
  expect_null(arg_atomic(mat))
  expect_error(arg_atomic(dat))
  expect_error(arg_atomic(lis), "must be an atomic vector", fixed = TRUE)
  expect_error(arg_atomic(NULL))
})

test_that("arg_vector() additionally rejects objects with a dims attribute", {
  vec <- 1:6
  mat <- as.matrix(vec)

  expect_null(arg_vector(vec))
  expect_error(arg_vector(mat), "must be a vector", fixed = TRUE)
})

test_that("arg_list() checks for lists and optionally rejects data frames", {
  lis <- list(1, 2)
  dat <- data.frame(x = 1)

  expect_null(arg_list(lis))
  expect_error(arg_list(dat), "must be a list and not a data frame", fixed = TRUE)
  expect_null(arg_list(dat, df_ok = TRUE))
  expect_error(arg_list(1:3), "must be a list", fixed = TRUE)
  expect_error(arg_list(lis, df_ok = "yes"))
})

test_that("arg_data.frame() checks for data frames", {
  dat <- data.frame(x = 1)
  expect_null(arg_data.frame(dat))
  expect_error(arg_data.frame(1:3), "must be a data frame", fixed = TRUE)
})

test_that("arg_matrix() checks for matrices", {
  mat <- matrix(1:6, ncol = 2)
  expect_null(arg_matrix(mat))
  expect_error(arg_matrix(1:6), "must be a matrix", fixed = TRUE)
})

test_that("arg_array() checks for arrays", {
  arr <- array(1:8, c(2, 2, 2))
  expect_null(arg_array(arr))
  expect_error(arg_array(1:6), "must be an array", fixed = TRUE)
})

test_that("arg_data() accepts data frames or matrices only", {
  dat <- data.frame(x = 1)
  mat <- matrix(1:6, ncol = 2)
  expect_null(arg_data(dat))
  expect_null(arg_data(mat))
  expect_error(arg_data(1:6), "must be a data frame or matrix", fixed = TRUE)
  expect_error(arg_data(list(1)))
})

test_that("arg_env() checks for environments", {
  expect_null(arg_env(globalenv()))
  expect_null(arg_env(new.env()))
  expect_error(arg_env(1), "must be an environment", fixed = TRUE)
  expect_error(arg_env(list()))
})

test_that("arg_data() family respects a custom .msg", {
  expect_error(arg_matrix(1, .msg = "custom failure"), "ustom failure", fixed = TRUE)
})
