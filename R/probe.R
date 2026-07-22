# Mutable package-internal state for the arg_or()/arg_and() probe fast-path.
#
# When `arg_or()`/`arg_and()` first evaluate their checks, they only need to know
# which checks pass or fail -- not the (expensive) error messages, which are
# discarded whenever a sibling check ends up satisfying the combination. During
# that "probe" pass `.arg_state$probe` is set to TRUE, and err() short-circuits
# to raising `.arg_probe_cnd` (below) instead of building a cli-formatted error.
# If the full error message is actually needed (all checks fail), the outermost
# call turns the flag off and re-runs the checks through the normal path.
.arg_state <- new.env(parent = emptyenv())
.arg_state$probe <- FALSE

# A pre-built, message-less error condition raised (via base stop(), so no
# backtrace is captured) by err() during a probe pass. Reused for every probed
# failure; catching handlers that add classes operate on a copy, so this
# constant is never mutated.
.arg_probe_cnd <- structure(
  list(message = "", call = NULL),
  class = c("arg_probe_fail", "error", "condition")
)
