test_that("arg_between() accepts values within the default and custom range", {
  expect_null(arg_between(0.5))
  expect_null(arg_between(0))
  expect_null(arg_between(1))
  expect_null(arg_between(2, c(1, 3)))
  expect_null(arg_between(2, c(1, 2)))
})

test_that("arg_between() rejects values outside the range", {
  z <- 2
  expect_error(arg_between(z, c(1, 2), inclusive = FALSE),
               "`z` must be between 1 and 2 (exclusive)", fixed = TRUE)
  expect_error(arg_between(5, c(1, 2)),
               "must be between 1 and 2", fixed = TRUE)
})

test_that("arg_between() supports asymmetric inclusive bounds", {
  z <- 2
  expect_error(arg_between(z, c(1, 2), inclusive = c(TRUE, FALSE)),
               "`z` must be greater than or equal to 1 and less than 2", fixed = TRUE)
  expect_null(arg_between(1, c(1, 2), inclusive = c(TRUE, FALSE)))
  expect_error(arg_between(2, c(1, 2), inclusive = c(TRUE, FALSE)))
})

test_that("arg_between() reorders an unsorted range", {
  expect_null(arg_between(2, c(3, 1)))
  expect_error(arg_between(5, c(3, 1)),
               "must be between 1 and 3", fixed = TRUE)
})

test_that("arg_between() validates its own arguments", {
  expect_error(arg_between(1, range = 1))
  expect_error(arg_between(1, inclusive = "yes"))
  expect_error(arg_between(1, inclusive = c(TRUE, FALSE, TRUE)))
})

test_that("arg_between() errors when x and range/bound are not comparable types", {
  expect_error(arg_between("a", c(1, 2)))
  expect_error(arg_lte(2, "3"))
})

test_that("arg_between() vectorizes with 'each element of' phrasing", {
  expect_null(arg_between(c(0.2, 0.5, 0.8)))
  expect_error(arg_between(c(0.2, 1.5)),
               "Each element of", fixed = TRUE)
})

test_that("arg_between() errors on NA values (not silently dropped)", {
  expect_error(arg_between(NA))
  expect_error(arg_between(c(0.5, NA)))
})

test_that("arg_gt() checks strictly-greater-than, with 'positive' shorthand at bound 0", {
  expect_null(arg_gt(1))
  expect_error(arg_gt(0), "must be positive", fixed = TRUE)
  expect_error(arg_gt(2, 2), "must be greater than 2", fixed = TRUE)
  expect_null(arg_gt(3, 2))
  expect_error(arg_gt(c(1, 2, -1), 0),
               "Each element of `c(1, 2, -1)` must be positive", fixed = TRUE)
})

test_that("arg_gte() checks greater-than-or-equal", {
  expect_null(arg_gte(2, 2))
  expect_error(arg_gte(1, 2),
               "must be greater than or equal to 2", fixed = TRUE)
})

test_that("arg_gte() reports not-comparable types distinctly", {
  expect_error(arg_gte("a", 2),
               "must be comparable to 2 and be greater than or equal to 2", fixed = TRUE)
})

test_that("arg_lt() checks strictly-less-than, with 'negative' shorthand at bound 0", {
  expect_null(arg_lt(-1))
  expect_error(arg_lt(0), "must be negative", fixed = TRUE)
  expect_error(arg_lt(2, 2), "must be less than 2", fixed = TRUE)
})

test_that("arg_lte() checks less-than-or-equal", {
  expect_null(arg_lte(2, 2))
  expect_error(arg_lte(3, 2),
               "must be less than or equal to 2", fixed = TRUE)
})

test_that("arg_gt()/arg_gte()/arg_lt()/arg_lte() validate the bound argument", {
  expect_error(arg_gt(1, bound = c(1, 2)))
  expect_error(arg_lte(1, bound = c(1, 2)))
})

test_that("arg_between() family uses the caller's argument name by default", {
  f <- function(some_arg) arg_gt(some_arg, 0)
  expect_error(f(-1), "`some_arg`", fixed = TRUE)
})

test_that("arg_between() family respects a custom .msg", {
  cnd <- rlang::catch_cnd(arg_gt(-1, .msg = "custom failure message"))
  expect_identical(conditionMessage(cnd), "Custom failure message.")
})

test_that("arg_between() family works for Date objects, which are comparable but not numeric or character", {
  d1 <- as.Date("2020-01-01")
  d2 <- as.Date("2020-06-01")
  d3 <- as.Date("2020-12-31")

  expect_false(is.numeric(d1))
  expect_false(is.character(d1))

  expect_null(arg_between(d2, c(d1, d3)))
  expect_error(arg_between(d1, c(d2, d3)), "must be between", fixed = TRUE)

  expect_null(arg_gt(d2, d1))
  expect_error(arg_gt(d1, d2), "must be greater than", fixed = TRUE)

  expect_null(arg_gte(d1, d1))
  expect_null(arg_lte(d1, d1))
  expect_null(arg_lt(d1, d2))
  expect_error(arg_lt(d2, d1))
})

test_that("arg_between() family works for ordered factors, which have Ops.factor comparison methods", {
  levels <- c("low", "medium", "high")
  f1 <- factor("low", levels = levels, ordered = TRUE)
  f2 <- factor("medium", levels = levels, ordered = TRUE)
  f3 <- factor("high", levels = levels, ordered = TRUE)

  expect_null(arg_gt(f2, f1))
  expect_error(arg_gt(f1, f2))
  expect_null(arg_lt(f1, f2))
  expect_null(arg_between(f2, c(f1, f3)))
  expect_error(arg_between(f1, c(f2, f3)))
})

test_that("arg_between() family works for any custom class with Ops methods defined", {
  # Ops methods must be visible on the search path for S3 dispatch to find
  # them, so this registers Ops.money on the global environment for the
  # duration of the test and removes it again afterward.
  Ops.money <- function(e1, e2) {
    v1 <- if (inherits(e1, "money")) unclass(e1) else e1
    v2 <- if (inherits(e2, "money")) unclass(e2) else e2
    get(.Generic)(v1, v2)
  }
  assign("Ops.money", Ops.money, envir = globalenv())
  on.exit(rm("Ops.money", envir = globalenv()))

  money <- function(x) structure(x, class = "money")
  m1 <- money(5)
  m2 <- money(10)

  expect_null(arg_gt(m2, m1))
  expect_error(arg_gt(m1, m2), "must be greater than", fixed = TRUE)
  expect_null(arg_between(m2, c(m1, money(15))))
})

test_that("arg_between() respects a custom .msg", {
  cnd <- rlang::catch_cnd(arg_between(5, c(1, 2), .msg = "custom between msg"))
  expect_identical(conditionMessage(cnd), "Custom between msg.")
})

test_that("arg_between() covers mixed-inclusive gt_str/lt_str shorthand branches", {
  expect_error(arg_between(-1, c(0, 5), inclusive = c(FALSE, TRUE)),
               "must be positive and less than or equal to 5", fixed = TRUE)
  expect_error(arg_between(-1, c(1, 5), inclusive = c(FALSE, TRUE)),
               "must be greater than 1 and less than or equal to 5", fixed = TRUE)
  expect_error(arg_between(6, c(-5, 0), inclusive = c(TRUE, FALSE)),
               "must be greater than or equal to -5 and negative", fixed = TRUE)
})

test_that("arg_gte()/arg_lt()/arg_lte() respect a custom .msg", {
  expect_identical(conditionMessage(rlang::catch_cnd(arg_gte(-1, .msg = "custom gte msg"))),
                    "Custom gte msg.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_lt(1, .msg = "custom lt msg"))),
                    "Custom lt msg.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_lte(1, .msg = "custom lte msg"))),
                    "Custom lte msg.")
})

test_that("arg_between() family treats an object as not comparable if its comparison method errors or is undefined", {
  d1 <- as.Date("2020-01-01")
  expect_error(arg_gt(d1, 5))
  expect_error(arg_gt(d1, "2020-01-01"))

  no_ops <- structure(list(1), class = "no_ops_class")
  expect_error(arg_gt(no_ops, no_ops))
})
