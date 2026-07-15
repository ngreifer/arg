test_that("arg_color() accepts a single valid color and rejects invalid or non-scalar input", {
  expect_null(arg_color("red"))
  expect_null(arg_color("#A4A473"))
  expect_null(arg_color(15))
  expect_error(arg_color("redhehehe"), "must be a valid color", fixed = TRUE)
  expect_error(arg_color("~A4A473"))
  expect_error(arg_color(-15))
  expect_error(arg_color(c("red", "blue")), "must be a valid color", fixed = TRUE)
})

test_that("arg_colors() accepts a vector of valid colors", {
  expect_null(arg_colors(c("red", "blue")))
  expect_null(arg_colors(list("red", 15)))
  expect_error(arg_colors(c("red", "bad")),
               "Each element of `c(\"red\", \"bad\")` must be a valid color", fixed = TRUE)
  expect_error(arg_colors(list("red", -15)))
})

test_that("arg_colour() and arg_colours() are British-spelling equivalents", {
  expect_null(arg_colour("red"))
  expect_error(arg_colour("redhehehe"), "must be a valid colour", fixed = TRUE)

  expect_null(arg_colours(c("red", "blue")))
  expect_error(arg_colours(c("red", "bad")),
               "Each element of `c(\"red\", \"bad\")` must be a valid colour", fixed = TRUE)
})

test_that("arg_color() family respects a custom .msg", {
  expect_identical(conditionMessage(rlang::catch_cnd(arg_color("nope", .msg = "custom failure"))),
                    "Custom failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_colors(c("red", "bad"), .msg = "custom colors failure"))),
                    "Custom colors failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_colour("nope", .msg = "custom colour failure"))),
                    "Custom colour failure.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_colours(c("red", "bad"), .msg = "custom colours failure"))),
                    "Custom colours failure.")
})
