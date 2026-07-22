#' Check That Arguments Meet Some or All Criteria
#'
#' `arg_or()` checks whether an argument meets at least one given criterion. `arg_and()` checks whether an argument meets all given criteria.
#'
#' @inheritParams when_supplied
#' @inheritParams arg_is
#'
#' @details
#' For `arg_or()`, an error will be thrown only if `x` fails all of the supplied checks. This can be useful when an argument can take on one of several input types. For `arg_and()`, and error will be thrown if `x` fails any of the supplied checks. This is less useful on its own, as the checks can simply occur in sequence without `arg_and()`, but `arg_and()` can be supplied to the `...` argument of `arg_or()` to create more complicated criteria.
#'
#' The `...` arguments can be passed either as functions, e.g.,
#' ```
#' arg_or(x,
#'        arg_number,
#'        arg_string,
#'        arg_flag)
#' ```
#' or as unevaluated function calls with the `x` argument absent, e.g.,
#' ```
#' arg_or(x,
#'        arg_number(),
#'        arg_string(),
#'        arg_flag())
#' ```
#' or as a mixture of both.
#'
#' These functions do their best to provide a clean error message composed of all the error messages for the failed checks. With many options, this can yield a complicated error message, so use caution. `arg_and()` marks with a check (```r cli::symbol$tick```) any passed checks and with a cross (```r cli::symbol$cross```) any failed checks.
#'
#' @inherit arg_is return
#'
#' @seealso [arg_supplied()], [when_not_null()]
#'
#' @examples
#' # `arg_or()`
#' f <- function(z) {
#'   arg_or(z,
#'          arg_number,
#'          arg_string,
#'          arg_flag)
#' }
#'
#' try(f(1))      # No error
#' try(f("test")) # No error
#' try(f(TRUE))   # No error
#' try(f(1:4))    # Error: neither a number, string,
#' #              #        or flag, but a vector
#'
#' # `arg_and()`
#' g <- function(z) {
#'   arg_and(z,
#'           arg_counts,
#'           arg_length(len = 2),
#'           arg_lt(bound = 5))
#' }
#'
#' try(g(c(1, 2)))     # No error
#' try(g(c(1, 7)))     # Error: not < 5
#' try(g(c(1.1, 2.1))) # Error: not counts
#' try(g(4))           # Error: not length 2
#' try(g("bad"))       # Error: no criteria satisfied
#'
#' # Chaining together `arg_and()` and `arg_or()`
#' h <- function(z) {
#'   arg_or(z,
#'          arg_is_NA,
#'          arg_and(arg_count,
#'                  arg_lt(5)),
#'          arg_and(arg_string,
#'                  arg_element(c("a", "b", "c"))))
#' }
#'
#' try(h(NA))  # No error
#' try(h(1))   # No error
#' try(h("a")) # No error
#' try(h(7))   # Error: not < 5
#' try(h("d")) # Error: not in "a", "b", or "c"

#' @export
arg_or <- function(x, ..., .arg = rlang::caller_arg(x), .msg = NULL, .call) {
  force(.arg)

  if (...length() == 0L) {
    return(invisible())
  }

  dots <- rlang::call_match(dots_expand = FALSE)[["..."]]

  children <- vector("list", ...length())

  x_name <- rlang::caller_arg(x)

  # Fast probe pass: evaluate checks recording only pass/fail (err() short-circuits
  # to a message-less condition). If any check passes, return without ever building
  # the error messages that would be discarded anyway.
  prev_probe <- .arg_state$probe
  .arg_state$probe <- TRUE
  on.exit(.arg_state$probe <- prev_probe, add = TRUE)

  for (i in seq_along(dots)) {
    cnd <- .to_arg_fun_call(dots[[i]], x_name, .arg) |>
      eval.parent() |>
      rlang::catch_cnd()

    if (!inherits(cnd, "error")) {
      return(invisible())
    }

    if (rlang::cnd_inherits(cnd, "internal_arg_error")) {
      if (prev_probe) {
        stop(cnd)
      }
      break
    }
  }

  # All checks failed (or an internal error needs its real message). A nested
  # probe just signals failure cheaply; the outermost call turns the flag off and
  # rebuilds the full error through the normal path below.
  if (prev_probe) {
    stop(.arg_probe_cnd)
  }

  .arg_state$probe <- FALSE

  for (i in seq_along(dots)) {
    cnd <- .to_arg_fun_call(dots[[i]], x_name, .arg) |>
      eval.parent() |>
      rlang::catch_cnd()

    if (!inherits(cnd, "error")) {
      return(invisible())
    }

    if (rlang::cnd_inherits(cnd, "internal_arg_error")) {
      err("", .call = rlang::current_env(), parent = cnd)
    }

    children[[i]] <- .node_from_cnd(cnd)
  }

  if (is_not_null(.msg)) {
    err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
  }

  node <- list(kind = "or", passed = FALSE, children = children)

  .throw_arg_node(node, .arg, .call, environment())
}

#' @export
#' @rdname arg_or
arg_and <- function(x, ..., .arg = rlang::caller_arg(x), .msg = NULL, .call) {
  force(.arg)

  dots <- rlang::call_match(dots_expand = FALSE)[["..."]]

  children <- vector("list", ...length())
  failed <- rep.int(FALSE, ...length())

  x_name <- rlang::caller_arg(x)

  # Fast probe pass: record only pass/fail (err() short-circuits). Unlike arg_or(),
  # every check is scanned -- arg_and() surfaces an internal error from any position
  # even when other checks pass, so it must not short-circuit on the first failure.
  prev_probe <- .arg_state$probe
  .arg_state$probe <- TRUE
  on.exit(.arg_state$probe <- prev_probe, add = TRUE)

  any_failed <- FALSE

  for (i in seq_along(dots)) {
    cnd <- .to_arg_fun_call(dots[[i]], x_name, .arg) |>
      eval.parent() |>
      rlang::catch_cnd()

    if (rlang::cnd_inherits(cnd, "internal_arg_error")) {
      if (prev_probe) {
        stop(cnd)
      }
      any_failed <- TRUE
      break
    }

    if (inherits(cnd, "error")) {
      any_failed <- TRUE
    }
  }

  if (!any_failed) {
    return(invisible())
  }

  # A nested probe signals failure cheaply; the outermost call rebuilds the full
  # tick/cross error through the normal path below.
  if (prev_probe) {
    stop(.arg_probe_cnd)
  }

  .arg_state$probe <- FALSE

  for (i in seq_along(dots)) {
    cnd <- .to_arg_fun_call(dots[[i]], x_name, .arg) |>
      eval.parent() |>
      rlang::catch_cnd()

    if (rlang::cnd_inherits(cnd, "internal_arg_error")) {
      err("", .call = rlang::current_env(), parent = cnd)
    }

    if (inherits(cnd, "error")) {
      children[[i]] <- .node_from_cnd(cnd)
      failed[i] <- TRUE
    }
  }

  if (!any(failed)) {
    return(invisible())
  }

  if (is_not_null(.msg)) {
    err(.msg_eval(.msg), .call = .call, .envir = rlang::caller_env())
  }

  ## Build nodes for the passing checks (marked with a tick) by forcing each to
  ## fail via make_fail() so its descriptive message/structure can be recovered.
  for (i in which(!failed)) {
    cnd <- .to_arg_fun_call(dots[[i]], x_name, .arg) |>
      make_fail(x) |>
      eval.parent() |>
      rlang::catch_cnd()

    sub_node <- if (inherits(cnd, "error")) cnd[["arg_node"]] else NULL

    msg_i <- if (is_not_null(sub_node)) {
      render_inline(sub_node, .arg)
    }
    else if (inherits(cnd, "error")) {
      .normalize_msg(conditionMessage(cnd))
    }
    else {
      ""
    }

    children[[i]] <- list(kind = "leaf", passed = TRUE, msg = msg_i)
  }

  ## Drop duplicated or empty checks (keeping the first occurrence).
  keys <- vapply(children, render_inline, character(1L), .arg = .arg)
  keep <- !duplicated(keys) & nzchar(keys)
  children <- children[keep]

  node <- list(kind = "and", passed = FALSE, children = children)

  .throw_arg_node(node, .arg, .call, environment())
}

# Join combined items with `and_or`. When any item itself contains a comma, the
# 3-or-more-item separators become semicolons so nested commas stay unambiguous
# (e.g. "a function; a square, symmetric, numeric matrix; or a formula"). A two-
# item join never uses a comma separator, so it is always " and "/" or ".
.collapse_items <- function(items, and_or) {
  semi <- any(cli::ansi_grepl(",", items))

  cli::ansi_collapse(items,
                     sep = if (semi) "; " else ", ",
                     sep2 = sprintf(" %s ", and_or),
                     last = sprintf("%s %s ", if (semi) ";" else ",", and_or))
}

# Assign each message to a prefix group: the first prefix (in .prefixes() order)
# shared by >= 2 not-yet-grouped messages. Returns per-message integer group ids
# (NA when ungrouped) and the prefix template for each id. Ids start at
# `start_id` so several calls (e.g. one per passing status) can share a namespace.
.prefix_group_ids <- function(msgs, .arg, start_id = 1L) {
  prefixes <- .prefixes()
  env <- rlang::env(.arg = .arg)

  id <- rep(NA_integer_, length(msgs))
  templates <- list()
  remaining <- rep(TRUE, length(msgs))
  next_id <- start_id

  for (pi in seq_along(prefixes)) {
    prefix <- cli::format_inline(prefixes[pi], .envir = env)
    hits <- remaining & cli::ansi_grepl(paste0("^", prefix), msgs)

    if (sum(hits) < 2L) {
      next
    }

    id[hits] <- next_id
    templates[[as.character(next_id)]] <- prefixes[pi]
    remaining[hits] <- FALSE
    next_id <- next_id + 1L

    if (!any(remaining)) {
      break
    }
  }

  list(id = id, templates = templates, next_id = next_id)
}

# Render one prefix group: strip the shared prefix from each member and rejoin the
# remainders under it (e.g. "`x` must be" + {"a number", "a string"} ->
# "`x` must be a number or a string").
.render_prefix_group <- function(prefix_template, members, and_or, env) {
  prefix <- cli::format_inline(prefix_template, .envir = env)

  suffixes <- members |>
    ansi_trim(cli::ansi_nchar(prefix)) |>
    trim_final_punct() |>
    cli::ansi_trimws()

  paste(prefix, .collapse_items(suffixes, and_or))
}

# Combine messages that share a prefix into single "A, B, or C" items, preserving
# original order (each merged group takes the position of its first member).
.combine_ordered <- function(msgs, and_or, .arg) {
  groups <- .prefix_group_ids(msgs, .arg)
  env <- rlang::env(.arg = .arg)

  out <- character(0L)
  emitted <- integer(0L)

  for (i in seq_along(msgs)) {
    gid <- groups[["id"]][i]

    if (is.na(gid)) {
      out <- c(out, msgs[i] |> cli::ansi_trimws() |> trim_final_punct())
    }
    else if (!(gid %in% emitted)) {
      members <- msgs[which(groups[["id"]] == gid)]
      out <- c(out,
               .render_prefix_group(groups[["templates"]][[as.character(gid)]],
                                    members, and_or, env))
      emitted <- c(emitted, gid)
    }
  }

  out
}

.prefixes <- function() {
  p <- c(
    "{.arg {(.arg)}} must inherit from",
    "{.arg {(.arg)}} must be",
    "{.arg {(.arg)}} must have",
    "{.arg {(.arg)}}"
  )

  c(p, paste("each element of", p))
}

# The combining logic in arg_or()/arg_and() represents each check's result as a
# "node": a leaf (a single check) or a compound node (a nested arg_and()/arg_or()).
# Compound nodes carry their structure directly (attached to the thrown condition
# via `arg_node`), so parents never re-parse a rendered message string -- this is
# what lets nested and/or combinations render as a clean indented cascade.
#
#   list(kind = "leaf" | "and" | "or",
#        passed = TRUE/FALSE,
#        msg = <string>,             # leaf only
#        children = <list of nodes>) # compound only

# Collapse whitespace runs (including cli's word-wrap newlines) so a leaf's
# message is a single clean line, and drop any terminal punctuation (bullets
# carry none; a lone top-level message gets its period back from err()); the
# renderers own the final layout.
.normalize_msg <- function(msg) {
  msg <- cli::ansi_simplify(msg)
  gsub("[[:space:]]+", " ", cli::ansi_trimws(msg)) |>
    trim_final_punct()
}

# Build a node from a caught error condition: use its attached structured node
# if present (a nested arg_and()/arg_or()), otherwise treat it as a failed leaf.
.node_from_cnd <- function(cnd) {
  node <- cnd[["arg_node"]]

  if (is_not_null(node)) {
    node[["passed"]] <- FALSE
    return(node)
  }

  list(kind = "leaf", passed = FALSE, msg = .normalize_msg(conditionMessage(cnd)))
}

# Render a node to a single-line summary sentence (used for a passing nested
# check shown with a tick, and for the collapse of a lone nested check).
render_inline <- function(node, .arg) {
  if (identical(node[["kind"]], "leaf")) {
    return(node[["msg"]] |> cli::ansi_trimws() |> trim_final_punct())
  }

  and_or <- node[["kind"]]

  parts <- vapply(node[["children"]], render_inline, character(1L), .arg = .arg)

  combined <- .combine_ordered(parts, and_or, .arg)

  # Lowercase the leading letter of each continuation piece so the joined
  # sentence reads naturally (e.g. "... and each element ...", not "... and Each").
  if (length(combined) > 1L) {
    combined[-1L] <- ansi_lower_first(combined[-1L])
  }

  .collapse_items(combined, and_or)
}

# Return the bullet glyph cli renders for a given bullet name ("v" tick, "x"
# cross, "*" bullet), sourced from cli::cli_bullets() so it matches a standard
# cli condition exactly -- following the active cli theme, symbols, and colour
# support -- rather than hard-coding the styling.
.themed_glyph <- function(name) {
  setNames("PLACEHOLDERXYZ", name) |>
    cli::cli_bullets() |>
    cli::cli_fmt() |>
    sub(pattern = "[[:space:]]*PLACEHOLDERXYZ.*$",
        replacement = "")
}

# Turn a compound node's children into ordered render entries. Leaf children that
# share a prefix are merged into one item -- for "and" only within the same
# passing status, so a merged line keeps an unambiguous tick/cross -- while
# compound children are expanded as their own blocks. Original order is preserved
# (a merged group takes the position of its first member). Each entry carries a
# bullet name ("v" tick, "x" cross, "*" bullet) and its physical lines.
.render_children <- function(node, .arg) {
  children <- node[["children"]]
  kind <- node[["kind"]]

  is_leaf <- vapply(children, function(ch) identical(ch[["kind"]], "leaf"), logical(1L))
  passed <- vapply(children, function(ch) isTRUE(ch[["passed"]]), logical(1L))

  # arg_and() groups leaves only within a single passing status; arg_or() has one
  # status (all of its children failed).
  status_sets <- if (identical(kind, "and")) {
    list(which(is_leaf & passed), which(is_leaf & !passed))
  }
  else {
    list(which(is_leaf))
  }

  group_id <- rep(NA_integer_, length(children))
  templates <- list()
  next_id <- 1L

  for (idx in status_sets) {
    if (length(idx) < 2L) {
      next
    }

    msgs <- vapply(children[idx], function(ch) ch[["msg"]], character(1L))
    groups <- .prefix_group_ids(msgs, .arg, next_id)

    hit <- !is.na(groups[["id"]])
    group_id[idx[hit]] <- groups[["id"]][hit]
    templates <- c(templates, groups[["templates"]])
    next_id <- groups[["next_id"]]
  }

  env <- rlang::env(.arg = .arg)
  and_or <- kind

  role_of <- function(i) {
    if (identical(kind, "or")) "*" else if (passed[i]) "v" else "x"
  }

  entries <- list()
  emitted <- integer(0L)

  for (i in seq_along(children)) {
    if (!is_leaf[i]) {
      entries <- c(entries, list(list(role = role_of(i),
                                      lines = render_block(children[[i]], .arg))))
    }
    else if (is.na(group_id[i])) {
      lines <- children[[i]][["msg"]] |>
        cli::ansi_trimws() |>
        trim_final_punct() |>
        as.character()

      entries <- c(entries, list(list(role = role_of(i), lines = lines)))
    }
    else if (!(group_id[i] %in% emitted)) {
      members <- vapply(children[which(group_id == group_id[i])],
                        function(ch) ch[["msg"]], character(1L))
      merged <- .render_prefix_group(templates[[as.character(group_id[i])]],
                                     members, and_or, env)
      entries <- c(entries, list(list(role = role_of(i), lines = merged)))
      emitted <- c(emitted, group_id[i])
    }
  }

  entries
}

# Render a node to a vector of physical lines. Compound children that failed are
# expanded as indented sub-blocks (first line prefixed with the parent's glyph,
# subsequent lines indented two spaces); passing/leaf children are single lines.
render_block <- function(node, .arg) {
  if (identical(node[["kind"]], "leaf")) {
    return(node[["msg"]])
  }

  header <- if (identical(node[["kind"]], "or")) {
    "At least one of the following conditions must be met:"
  }
  else {
    "All of the following conditions must be met:"
  }

  entries <- .render_children(node, .arg)

  # A lone entry needs no header: return the single message, or the nested block
  # directly, so we don't double-wrap.
  if (length(entries) == 1L) {
    return(entries[[1L]][["lines"]])
  }

  # Source the bullet glyphs from cli so they match a standard cli condition
  # exactly, following the active cli theme, symbols, and colour support.
  glyphs <- c("*" = .themed_glyph("*"),
              "v" = .themed_glyph("v"),
              "x" = .themed_glyph("x"))

  out <- header

  for (e in entries) {
    lines <- e[["lines"]]
    out <- c(out, paste0(glyphs[[e[["role"]]]], " ", lines[1L]))

    if (length(lines) > 1L) {
      out <- c(out, paste0("  ", lines[-1L]))
    }
  }

  out
}

# Render a node and throw it. A single-line result goes through err() (which
# capitalizes and adds a period); a multi-line cascade is emitted verbatim with
# use_cli_format = FALSE so rlang preserves the manual indentation. The node is
# attached so an enclosing arg_and()/arg_or() can reuse its structure.
.throw_arg_node <- function(node, .arg, .call, .frame) {
  if (rlang::is_missing(.call)) {
    .call <- .pkg_caller_call()
  }

  lines <- render_block(node, .arg)

  if (is_scalar(lines)) {
    err(lines, .call = .call, .envir = .frame, arg_node = node)
  }

  paste(lines, collapse = "\n") |>
    cli::ansi_simplify() |>
    rlang::abort(call = .call, use_cli_format = FALSE,
                 .frame = .frame, arg_node = node)
}
