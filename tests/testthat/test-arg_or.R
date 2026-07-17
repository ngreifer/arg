test_that("arg_or() passes if x satisfies at least one check, using bare function names", {
  f <- function(z) arg_or(z, arg_number, arg_string, arg_flag)
  expect_null(f(1))
  expect_null(f("test"))
  expect_null(f(TRUE))
  expect_error(f(1:4), "must be", fixed = TRUE)
})

test_that("arg_or() accepts unevaluated call syntax with x omitted", {
  f2 <- function(z) arg_or(z, arg_number(), arg_string(), arg_flag())
  expect_null(f2(1))
  expect_null(f2("test"))
  expect_error(f2(1:4))
})

test_that("arg_or() combines failure messages into a single readable error", {
  f <- function(z) arg_or(z, arg_number, arg_string, arg_flag)
  expect_error(f(1:4),
               "a single number, a string, or a single logical value", fixed = TRUE)
})

test_that("arg_or() with no checks supplied is a no-op", {
  expect_null(arg_or(1))
})

test_that("arg_and() passes only if x satisfies every check", {
  g <- function(z) arg_and(z, arg_counts, arg_length(len = 2), arg_lt(bound = 5))
  expect_null(g(c(1, 2)))
  expect_error(g(c(1, 7)), "Each element of `z` must be less than 5", fixed = TRUE)
  expect_error(g(c(1.1, 2.1)))
  expect_error(g(4))
})

test_that("arg_and() marks passed checks with a tick and failed checks with a cross", {
  withr::local_options(cli.unicode = TRUE, cli.num_colors = 1, width = 200)
  # The two passing checks share a prefix and status, so they group onto one
  # ticked line; the failing check is a separate crossed line.
  g <- function(z) arg_and(z, arg_counts, arg_length(len = 2), arg_lt(bound = 5))
  cnd <- rlang::catch_cnd(g(c(1, 7)))
  msg <- conditionMessage(cnd)
  expect_match(msg, "All of the following conditions must be met", fixed = TRUE)

  tick <- cli::symbol$tick
  cross <- cli::symbol$cross

  expect_match(msg,
               paste0(tick, " `z` must be a vector of counts (non-negative whole numeric values) and must have length 2"),
               fixed = TRUE)
  expect_match(msg, paste0(cross, " Each element of `z` must be less than 5"), fixed = TRUE)
})

test_that("arg_and() reports a single failure message directly, without a bulleted list", {
  g <- function(z) arg_and(z, arg_counts, arg_length(len = 2), arg_lt(bound = 5))
  expect_error(g("bad"), "All of the following conditions must be met", fixed = TRUE)
})

test_that("arg_and() and arg_or() can be chained together", {
  h <- function(z) {
    arg_or(z,
           arg_all_NA,
           arg_and(arg_count, arg_lt(5)),
           arg_and(arg_string, arg_element(c("a", "b", "c"))))
  }
  expect_null(h(NA))
  expect_null(h(1))
  expect_null(h("a"))
  expect_error(h(7), "At least one of the following conditions must be met", fixed = TRUE)
  expect_error(h("d"))
})

test_that("arg_or() and arg_and() respect a custom .msg", {
  f <- function(z) arg_or(z, arg_number, .msg = "custom failure")
  expect_identical(conditionMessage(rlang::catch_cnd(f("a"))), "Custom failure.")

  g <- function(z) arg_and(z, arg_number, .msg = "custom failure")
  expect_identical(conditionMessage(rlang::catch_cnd(g("a"))), "Custom failure.")
})

test_that("arg_or() propagates internal argument errors from malformed checks", {
  f <- function(z) arg_or(z, arg_length(len = "a"))
  expect_error(f(1))
})

test_that("arg_or() wrapping a single nested arg_or() unwraps to that nested message", {
  # arg_between() and arg_flag() share the "must be" prefix and get merged into
  # one bullet by the nested arg_or(); arg_is()'s "must inherit from" message
  # is a second, separate bullet -- so the nested arg_or() fails with a genuine
  # two-bullet "At least one of ..." message. Because it is the outer arg_or()'s
  # sole check, the outer call unwraps to that nested message directly (no
  # redundant double header), keeping the two bullets delineated.
  withr::local_options(cli.unicode = TRUE, cli.num_colors = 1, width = 200)
  bull <- cli::symbol$bullet

  f <- function(z) {
    arg_or(z,
           arg_or(arg_is("nonexistent_class"),
                  arg_between(range = c(100, 200)),
                  arg_flag))
  }
  msg <- conditionMessage(rlang::catch_cnd(f(5)))

  # Grouping preserves original order, so arg_is()'s "must inherit from" bullet
  # (the first check) comes before the merged between/flag bullet.
  expected <- paste(
    "At least one of the following conditions must be met:",
    paste0(bull, " `z` must inherit from class <nonexistent_class>"),
    paste0(bull, " `z` must be between 100 and 200 (inclusive) or a logical value (TRUE or FALSE)"),
    sep = "\n"
  )
  expect_identical(msg, expected)
})

test_that("arg_or() surfaces only the internal argument error, not a mix of it and a prior check's user-facing failure", {
  # arg_string(1) fails first (a normal, user-facing failure) and is recorded
  # internally; arg_length(len = "a") then raises an internal_arg_error, which
  # should immediately replace the whole result, not be appended to or merged
  # with the already-recorded arg_string() failure message.
  f <- function(z) arg_or(z, arg_string, arg_length(len = "a"))
  cnd <- rlang::catch_cnd(f(1))
  msg <- conditionMessage(cnd)

  expect_match(msg, "must be a vector of counts", fixed = TRUE)
  expect_false(grepl("must be a string", msg, fixed = TRUE))
  expect_false(grepl("at least one of the following", msg, ignore.case = TRUE))
})

test_that("arg_and() propagates internal argument errors from malformed checks", {
  f <- function(z) arg_and(z, arg_number, arg_length(len = "a"))
  expect_error(f(1))
  expect_error(f("a"))
})

test_that("deeply nested and/or renders as a clean cascade under non-UTF-8 output (regression)", {
  # Regression test: nested compound messages used to be combined by re-parsing
  # the child's rendered string and splitting it on cli::symbol() glyphs. Under
  # non-UTF-8 output (the default in non-interactive R sessions, incl. testthat)
  # those glyphs are ordinary letters (tick = "v", cross = "x"), so ordinary
  # words like "non-negative" got shredded. The structured-node renderer never
  # re-parses rendered strings, so words stay intact and the cascade is clean.
  withr::local_options(cli.unicode = FALSE, cli.num_colors = 1, width = 200)

  h <- function(z) {
    arg_or(z,
           arg_is_NA,
           arg_and(arg_count, arg_lt(5)),
           arg_and(arg_string, arg_element(c("a", "b", "c"))))
  }
  msg <- conditionMessage(rlang::catch_cnd(h("d")))

  # Words intact (not shredded on ASCII-fallback glyph letters):
  expect_match(msg, "a count (a non-negative whole number)", fixed = TRUE)
  expect_match(msg, 'must be one of "a", "b", or "c"', fixed = TRUE)
  # Cascade structure present: outer OR header + nested AND sub-blocks.
  expect_match(msg, "At least one of the following conditions must be met:", fixed = TRUE)
  expect_match(msg, "All of the following conditions must be met:", fixed = TRUE)

  g <- function(z) arg_and(z, arg_and(arg_number, arg_string), arg_flag)
  msg2 <- conditionMessage(rlang::catch_cnd(g(list())))
  expect_match(msg2, "`z` must be a single number and a string", fixed = TRUE)
  expect_match(msg2, "`z` must be a single logical value (TRUE or FALSE)", fixed = TRUE)
})

test_that("a single-condition failure is reported as one plain sentence (no header/bullets)", {
  # A lone check collapses to a single message that is thrown through err(),
  # which capitalizes it and adds a terminal period.
  expect_identical(conditionMessage(rlang::catch_cnd(arg_and(5, arg_string))),
                   "`5` must be a string.")
  expect_identical(conditionMessage(rlang::catch_cnd(arg_or(5, arg_string))),
                   "`5` must be a string.")
})

test_that("alternating arg_and()/arg_or() nesting renders as an indented cascade", {
  # AND containing OR containing ANDs: each level is delineated with its own
  # header, ticks/crosses (arg_and) or bullets (arg_or), and 2-space-per-level
  # indentation. A passing nested check (the first arg_or here) collapses to a
  # single ticked summary line.
  withr::local_options(cli.unicode = TRUE, cli.num_colors = 1, width = 200)
  tick <- cli::symbol$tick
  cross <- cli::symbol$cross
  bull <- cli::symbol$bullet

  f <- function(z) {
    arg_and(z,
            arg_or(arg_character, arg_numeric),
            arg_or(arg_and(arg_all_NA, arg_length(1L)),
                   arg_and(arg_no_NA, arg_length(2L))))
  }
  msg <- conditionMessage(rlang::catch_cnd(f(1)))

  expected <- paste(
    "All of the following conditions must be met:",
    paste0(tick, " `z` must be a character vector or a numeric vector"),
    paste0(cross, " At least one of the following conditions must be met:"),
    paste0("  ", bull, " All of the following conditions must be met:"),
    paste0("    ", cross, " `z` must only contain NA values"),
    paste0("    ", tick, " `z` must have length 1"),
    paste0("  ", bull, " All of the following conditions must be met:"),
    paste0("    ", tick, " `z` must not contain NA values"),
    paste0("    ", cross, " `z` must have length 2"),
    sep = "\n"
  )
  expect_identical(msg, expected)
})

test_that("bullet glyphs match a native cli condition's styling (theme-aware, not hard-coded)", {
  # The tick/cross/bullet glyphs are sourced from cli itself, so they must be
  # byte-identical to the glyphs a standard cli::cli_abort() emits for the
  # "v"/"x"/"*" bullets -- under the active colour/unicode/theme settings.
  withr::local_options(cli.unicode = TRUE, cli.num_colors = 256, width = 200)

  # The glyphs cli renders for a real condition.
  native <- rlang::catch_cnd(cli::cli_abort(c("H", "v" = "a", "x" = "b", "*" = "c")))
  native_lines <- strsplit(conditionMessage(native), "\n", fixed = TRUE)[[1L]]
  glyph_of <- function(line) sub(" .*$", "", line)   # styled glyph before first space
  native_tick <- glyph_of(native_lines[2L])
  native_cross <- glyph_of(native_lines[3L])
  native_bullet <- glyph_of(native_lines[4L])

  # ANSI colour must actually be present (guards against a silent no-colour run).
  expect_match(native_tick, "\033", fixed = TRUE)

  f <- function(z) {
    arg_and(z,
            arg_or(arg_character, arg_numeric),
            arg_and(arg_no_NA, arg_length(2L)))
  }
  msg <- conditionMessage(rlang::catch_cnd(f(1)))
  expect_true(grepl(native_tick, msg, fixed = TRUE))
  expect_true(grepl(native_cross, msg, fixed = TRUE))

  g <- function(z) arg_or(z, arg_and(arg_number, arg_string),
                          arg_and(arg_character, arg_length(2L)))
  msg2 <- conditionMessage(rlang::catch_cnd(g(TRUE)))
  expect_true(grepl(native_bullet, msg2, fixed = TRUE))
})

test_that("render_block() lays out nodes with per-level glyphs and indentation", {
  withr::local_options(cli.unicode = TRUE, cli.num_colors = 1, width = 200)
  tick <- cli::symbol$tick
  cross <- cli::symbol$cross
  bull <- cli::symbol$bullet

  leaf <- function(passed, msg) list(kind = "leaf", passed = passed, msg = msg)

  # A leaf node renders to its message verbatim.
  expect_identical(arg:::render_block(leaf(FALSE, "`z` must be a number"), "z"),
                   "`z` must be a number")

  # AND: header + one tick/cross line per child.
  and_node <- list(kind = "and", passed = FALSE,
                   children = list(leaf(TRUE, "`z` must be a"),
                                   leaf(FALSE, "`z` must be b")))
  expect_identical(
    arg:::render_block(and_node, "z"),
    c("All of the following conditions must be met:",
      paste0(tick, " `z` must be a"),
      paste0(cross, " `z` must be b"))
  )

  # A failed compound child is expanded as an indented sub-block under the glyph.
  nested <- list(kind = "and", passed = FALSE,
                 children = list(leaf(TRUE, "`z` must be a"), and_node))
  expect_identical(
    arg:::render_block(nested, "z"),
    c("All of the following conditions must be met:",
      paste0(tick, " `z` must be a"),
      paste0(cross, " All of the following conditions must be met:"),
      paste0("  ", tick, " `z` must be a"),
      paste0("  ", cross, " `z` must be b"))
  )

  # A lone entry needs no header (single message unwrapped).
  solo <- list(kind = "or", passed = FALSE,
               children = list(leaf(FALSE, "`z` must be a number")))
  expect_identical(arg:::render_block(solo, "z"), "`z` must be a number")

  # OR: leaf siblings sharing a prefix merge into one alternative -- which,
  # being the only entry, unwraps to a single headerless line.
  merged_or <- list(kind = "or", passed = FALSE,
                    children = list(leaf(FALSE, "`z` must be a number"),
                                    leaf(FALSE, "`z` must be a string")))
  expect_identical(arg:::render_block(merged_or, "z"),
                   "`z` must be a number or a string")

  # OR with leaves in different prefix families (one "`z` ...", one "each
  # element of `z` ..."): nothing merges, so header + one bullet per alternative.
  or_node <- list(kind = "or", passed = FALSE,
                  children = list(leaf(FALSE, "`z` must be a number"),
                                  leaf(FALSE, "each element of `z` must be less than 5")))
  expect_identical(
    arg:::render_block(or_node, "z"),
    c("At least one of the following conditions must be met:",
      paste0(bull, " `z` must be a number"),
      paste0(bull, " each element of `z` must be less than 5"))
  )
})

test_that("render_inline() collapses a node to a single readable sentence", {
  leaf <- function(msg) list(kind = "leaf", passed = FALSE, msg = msg)

  or_node <- list(kind = "or", passed = FALSE,
                  children = list(leaf("`z` must be a character vector"),
                                  leaf("`z` must be a numeric vector")))
  expect_identical(arg:::render_inline(or_node, "z"),
                   "`z` must be a character vector or a numeric vector")

  # Continuation pieces are lowercased so the conjunction reads naturally.
  and_node <- list(kind = "and", passed = FALSE,
                   children = list(leaf("`z` must be a single number"),
                                   leaf("Each element of `z` must be less than 10")))
  expect_identical(arg:::render_inline(and_node, "z"),
                   "`z` must be a single number and each element of `z` must be less than 10")
})

test_that("arg_or() uses semicolons to separate combined items that contain commas", {
  withr::local_options(cli.unicode = TRUE, cli.num_colors = 1, width = 200)

  # arg_cov()'s message ("a square, symmetric, numeric matrix") contains commas,
  # so the three merged alternatives are separated with semicolons rather than
  # commas to keep the list unambiguous.
  f <- function(vcov) arg_or(vcov, arg_function, arg_cov, arg_formula)
  expect_identical(
    conditionMessage(rlang::catch_cnd(f(1L))),
    "`vcov` must be a function; a square, symmetric, numeric matrix; or a formula."
  )

  # With no commas in any item, ordinary comma separators are used.
  g <- function(z) arg_or(z, arg_number, arg_string, arg_flag)
  expect_identical(
    conditionMessage(rlang::catch_cnd(g(1:4))),
    "`z` must be a single number, a string, or a single logical value (TRUE or FALSE)."
  )

  # A two-item join never uses a comma separator, so it stays " or " even when an
  # item contains commas.
  h <- function(vcov) arg_or(vcov, arg_cov, arg_formula)
  expect_identical(
    conditionMessage(rlang::catch_cnd(h(1L))),
    "`vcov` must be a square, symmetric, numeric matrix or a formula."
  )
})

test_that("arg_and() groups same-status checks that share a prefix into one line", {
  withr::local_options(cli.unicode = TRUE, cli.num_colors = 1, width = 200)
  tick <- cli::symbol$tick
  cross <- cli::symbol$cross

  # Two failing checks sharing a prefix collapse to one line (no header/bullets).
  vcov_strings <- c("HC0", "HC1", "HC2")
  f <- function(vcov) arg_and(vcov, arg_string, arg_element(vcov_strings))
  expect_identical(
    conditionMessage(rlang::catch_cnd(f(5))),
    '`vcov` must be a string and one of "HC0", "HC1", or "HC2".'
  )

  # Same-status checks group (the two failing "must be" checks merge onto one
  # crossed line, at the first one's position); a passing check keeps its own
  # ticked line and is not merged across statuses.
  h <- function(vcov) arg_and(vcov, arg_string, arg_element(vcov_strings), arg_numeric)
  msg <- conditionMessage(rlang::catch_cnd(h(5)))
  expected <- paste(
    "All of the following conditions must be met:",
    paste0(cross, ' `vcov` must be a string and one of "HC0", "HC1", or "HC2"'),
    paste0(tick, " `vcov` must be a numeric vector"),
    sep = "\n"
  )
  expect_identical(msg, expected)

  # Checks with different prefixes and mixed statuses are not grouped at all,
  # and original order is preserved.
  g <- function(z) arg_and(z, arg_number, arg_length(len = 2), arg_lt(bound = 5))
  msg2 <- conditionMessage(rlang::catch_cnd(g(c(1, 7))))
  expected2 <- paste(
    "All of the following conditions must be met:",
    paste0(cross, " `z` must be a single number"),
    paste0(tick, " `z` must have length 2"),
    paste0(cross, " Each element of `z` must be less than 5"),
    sep = "\n"
  )
  expect_identical(msg2, expected2)
})
