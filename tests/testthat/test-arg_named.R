test_that("arg_named() requires all names to be non-empty and non-NA", {
  obj <- c(1, B = 2, C = 3)
  expect_error(arg_named(obj), "must not have empty names", fixed = TRUE)

  names(obj)[1L] <- "A"
  expect_null(arg_named(obj))

  obj2 <- unname(obj)
  expect_error(arg_named(obj2), "must not have empty names", fixed = TRUE)
})

test_that("arg_named() reports NA names distinctly from empty names", {
  obj <- c(A = 1, B = 2)
  names(obj)[2L] <- NA
  expect_error(arg_named(obj), "NA", fixed = TRUE)
})

test_that("arg_named() does not consider matrices named, but does consider data frames named", {
  mat <- matrix(1:6, ncol = 2)
  colnames(mat) <- c("A", "B")
  expect_error(arg_named(mat), "must not have empty names", fixed = TRUE)

  dat <- as.data.frame(mat)
  expect_null(arg_named(dat))
})

test_that("arg_colnamed() requires all column names to be non-empty and non-NA", {
  mat <- matrix(1:6, ncol = 2)
  colnames(mat) <- c("A", "B")
  expect_null(arg_colnamed(mat))

  dat <- as.data.frame(mat)
  expect_null(arg_colnamed(dat))

  colnames(mat) <- NULL
  expect_error(arg_colnamed(mat), "must not have empty column names", fixed = TRUE)

  mat3 <- matrix(1:6, ncol = 2)
  colnames(mat3) <- c("A", "")
  expect_error(arg_colnamed(mat3), "must not have empty column names", fixed = TRUE)
})

test_that("arg_colnamed() reports NA column names distinctly from empty column names", {
  mat2 <- matrix(1:6, ncol = 2)
  colnames(mat2) <- c("A", NA)
  expect_error(arg_colnamed(mat2), "must not have NA values as column names", fixed = TRUE)
})

test_that("arg_named() family respects a custom .msg", {
  expect_error(arg_named(1:3, .msg = "custom failure"), "ustom failure", fixed = TRUE)
})
