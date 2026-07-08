test_that("arg_is() errors only when x inherits from none of the given classes", {
  obj <- structure(list(1), class = "test")

  expect_null(arg_is(obj, "test"))
  expect_null(arg_is(obj, c("test", "quiz")))
  expect_error(arg_is(obj, "quiz"), "must inherit from class", fixed = TRUE)
})

test_that("arg_is_not() errors when x inherits from any of the given classes", {
  obj <- structure(list(1), class = "test")

  expect_error(arg_is_not(obj, "test"), "must not inherit from class", fixed = TRUE)
  expect_error(arg_is_not(obj, c("test", "quiz")))
  expect_null(arg_is_not(obj, "quiz"))
})

test_that("arg_is() is permissive about multi-class objects (any match suffices)", {
  obj2 <- structure(list(1), class = c("test", "essay"))
  expect_null(arg_is(obj2, c("test", "quiz")))
  expect_error(arg_is_not(obj2, c("test", "quiz")))
})

test_that("arg_and() can require membership in multiple classes simultaneously", {
  obj2 <- structure(list(1), class = c("test", "essay"))
  expect_null(arg_and(obj2, arg_is("test"), arg_is("essay")))
  expect_error(arg_and(obj2, arg_is("test"), arg_is("quiz")))
})

test_that("arg_is() and arg_is_not() require a supplied, character class argument", {
  obj <- structure(list(1), class = "test")
  expect_error(arg_is(obj, NULL))
  expect_error(arg_is(obj, 1))
  expect_error(arg_is_not(obj, NULL))
})

test_that("arg_is() family respects a custom .msg", {
  obj <- structure(list(1), class = "test")
  expect_error(arg_is(obj, "quiz", .msg = "custom failure"), "ustom failure", fixed = TRUE)
})
