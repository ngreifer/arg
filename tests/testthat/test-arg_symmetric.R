test_that("arg_symmetric() requires a square, symmetric, numeric matrix", {
  set.seed(1234)
  m <- matrix(rnorm(12), ncol = 3L)
  sym_mat <- -crossprod(m)

  expect_error(arg_symmetric(m), "must be a square, symmetric, numeric matrix", fixed = TRUE)
  expect_null(arg_symmetric(sym_mat))
  expect_error(arg_symmetric(1:4))
})

test_that("arg_symmetric() with tol = Inf only checks squareness and numeric type", {
  expect_error(arg_symmetric(matrix(1:6, ncol = 3), tol = Inf),
               "must be a square, numeric matrix", fixed = TRUE)
  expect_null(arg_symmetric(matrix(1:4, ncol = 2), tol = Inf))
})

test_that("arg_cov() additionally requires a non-negative diagonal", {
  set.seed(1234)
  m <- matrix(rnorm(12), ncol = 3L)
  sym_mat <- -crossprod(m)
  cov_mat <- cov(m)

  expect_error(arg_cov(sym_mat),
               "must be a square, symmetric matrix with non-negative values on the diagonal",
               fixed = TRUE)
  expect_null(arg_cov(cov_mat))
})

test_that("arg_cor() additionally requires values in [-1, 1] and ones on the diagonal", {
  set.seed(1234)
  m <- matrix(rnorm(12), ncol = 3L)
  cov_mat <- cov(m)
  cor_mat <- cor(m)

  expect_error(arg_cor(cov_mat), "All values in `cov_mat` must be between -1 and 1", fixed = TRUE)
  expect_null(arg_cor(cor_mat))
})

test_that("arg_distance() additionally requires non-negative values and a zero diagonal", {
  set.seed(1234)
  m <- matrix(rnorm(12), ncol = 3L)
  cor_mat <- cor(m)
  dist_mat <- as.matrix(dist(m))

  expect_error(arg_distance(cor_mat),
               "must be a square, symmetric matrix with zeros on the diagonal", fixed = TRUE)
  expect_null(arg_distance(dist_mat))
})

test_that("arg_symmetric() family validates tol as a non-negative number", {
  m <- diag(2)
  expect_error(arg_symmetric(m, tol = -1))
  expect_error(arg_symmetric(m, tol = c(1, 2)))
})

test_that("arg_symmetric() family respects a custom .msg", {
  expect_identical(conditionMessage(rlang::catch_cnd(arg_symmetric(1:4, .msg = "custom failure"))),
                    "Custom failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_cov(1:4, .msg = "custom cov failure"))),
                    "Custom cov failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_cor(1:4, .msg = "custom cor failure"))),
                    "Custom cor failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_distance(1:4, .msg = "custom distance failure"))),
                    "Custom distance failure.")
})

test_that("arg_cov() reports non-symmetric matrices distinctly from a negative diagonal", {
  m <- matrix(1:4, ncol = 2)
  expect_error(arg_cov(m), "must be a square, symmetric, numeric matrix", fixed = TRUE)
})

test_that("arg_cor() reports non-symmetric matrices and out-of-range diagonals distinctly", {
  m <- matrix(1:4, ncol = 2)
  expect_error(arg_cor(m), "must be a square, symmetric, numeric matrix", fixed = TRUE)

  m2 <- matrix(c(0.5, 0.2, 0.2, 0.5), ncol = 2)
  expect_error(arg_cor(m2),
               "must be a square, symmetric matrix with ones on the diagonal", fixed = TRUE)
})

test_that("arg_distance() reports non-symmetric matrices and negative values distinctly", {
  m <- matrix(1:4, ncol = 2)
  expect_error(arg_distance(m), "must be a square, symmetric, numeric matrix", fixed = TRUE)

  m2 <- matrix(c(0, -1, -1, 0), ncol = 2)
  expect_error(arg_distance(m2), "All values in `m2` must be non-negative", fixed = TRUE)
})
