test_that("arg_logical() accepts logical vectors of any length and rejects other types", {
  expect_null(arg_logical(TRUE))
  expect_null(arg_logical(c(TRUE, FALSE)))
  expect_null(arg_logical(NA))
  expect_error(arg_logical(1L), "must be a logical vector", fixed = TRUE)
  expect_error(arg_logical("TRUE"))
})

test_that("arg_flag() requires a non-NA logical scalar", {
  expect_null(arg_flag(TRUE))
  expect_null(arg_flag(FALSE))
  expect_error(arg_flag(c(TRUE, FALSE)),
               "must be a single logical value (TRUE or FALSE)", fixed = TRUE)
  expect_error(arg_flag(1L), "must be a logical value (TRUE or FALSE)", fixed = TRUE)
  expect_error(arg_flag(NA), "must be a logical value (TRUE or FALSE)", fixed = TRUE)
})

test_that("arg_logical() family respects a custom .msg", {
  expect_identical(conditionMessage(rlang::catch_cnd(arg_flag(NA, .msg = "custom failure"))),
                    "Custom failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_logical(1L, .msg = "custom logical failure"))),
                    "Custom logical failure.")
})
