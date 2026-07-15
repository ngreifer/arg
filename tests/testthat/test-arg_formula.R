test_that("arg_formula() accepts one- and two-sided formulas by default", {
  form1 <- ~a + b
  form2 <- y ~ a + b
  not_form <- 1:3

  expect_null(arg_formula(form1))
  expect_null(arg_formula(form2))
  expect_error(arg_formula(not_form), "must be a formula", fixed = TRUE)
})

test_that("arg_formula() enforces sidedness when one_sided is specified", {
  form1 <- ~a + b
  form2 <- y ~ a + b

  expect_null(arg_formula(form1, one_sided = TRUE))
  expect_error(arg_formula(form2, one_sided = TRUE), "must be a one-sided formula", fixed = TRUE)

  expect_null(arg_formula(form2, one_sided = FALSE))
  expect_error(arg_formula(form1, one_sided = FALSE), "must be a two-sided formula", fixed = TRUE)
})

test_that("arg_formula() validates the one_sided argument", {
  expect_error(arg_formula(~a, one_sided = "yes"))
  expect_error(arg_formula(~a, one_sided = c(TRUE, FALSE)))
})

test_that("arg_formula() respects a custom .msg", {
  expect_identical(conditionMessage(rlang::catch_cnd(arg_formula(1, .msg = "custom failure"))),
                    "Custom failure.")
})
