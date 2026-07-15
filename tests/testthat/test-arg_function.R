test_that("arg_function() accepts functions and rejects non-functions", {
  expect_null(arg_function(print))
  expect_null(arg_function(function(x) x))
  expect_error(arg_function("print"), "must be a function", fixed = TRUE)
  expect_error(arg_function(1))
  expect_error(arg_function(NULL))
})

test_that("arg_function() respects a custom .msg", {
  expect_identical(conditionMessage(rlang::catch_cnd(arg_function(1, .msg = "custom failure"))),
                    "Custom failure.")
})
