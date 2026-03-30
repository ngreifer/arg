#' Argument Verification
#'
#' An alternative to [match.arg()] with improved
#' error messages via \pkg{cli}. Returns the first choice if `x` is `NULL`,
#' and supports partial matching.
#'
#' @inheritParams arg_is
#' @param x a string (or character vector if `several.ok = TRUE`) to match against `choices`. If `NULL`, the first element of `choices` is returned.
#' @param choices a character vector of valid values.
#' @param several.ok `logical`; if `TRUE`, `x` may contain more than one element. Defaults to `FALSE`.
#' @param ignore.case `logical`; if `FALSE`, the matching is case sensitive, and if `TRUE` (the default), case is ignored.
#' @param .context an optional character string providing context for error messages (e.g., a function or object name). Prepended to the error message when supplied before being evaluated by \pkg{cli}.
#'
#' @returns
#' A character string (or vector, if `several.ok = TRUE`) of the matched element(s) from `choices`. If there is no match, an error is thrown. When `several.ok = TRUE`, no error is thrown if there is at least one match.
#'
#' @details
#' Partial matching is supported via [pmatch()]. If no match is found, an error is thrown listing the valid `choices`.
#'
#' Checks are run on `x` prior to matching: first, [arg_supplied()] is used to check whether `x` was supplied; then [arg_string()] (if `several.ok = TRUE`) or [arg_character()] (if `several.ok = FALSE`) is used to check whether `x` is a valid string or character vector, respectively.
#'
#' When `ignore.case = TRUE` (the default), an initial case-sensitive match is run, and if any values in `x` are unmatched, a second, case-insensitive match is run. When `ignore.case = FALSE`, only the first match is run. This ensures that exact matches (on both content and case) are prioritized before case-insensitive matches.
#'
#' @seealso
#' * [match.arg()] for the base \R version
#' * [pmatch()] for the function implementing partial string matching
#' * [arg_element()] for a version without type checking and that doesn't support partial matching
#' * [rlang::arg_match()] for a similar \pkg{rlang} function that doesn't support partial matching.
#'
#' @examples
#' f <- function(z = NULL) {
#'   match_arg(z, c("None", "Exact", "Partial"),
#'             ignore.case = TRUE)
#' }
#'
#' try(f())            # "None" (first choice returned)
#' try(f("partial"))   # "Partial"
#' try(f("p"))         # "Partial" (partial match)
#' try(f(c("e", "p"))) # Error: several.ok = FALSE
#'
#' # several.ok = TRUE
#' g <- function(z = NULL) {
#'   match_arg(z, c("None", "Exact", "Partial"),
#'             several.ok = TRUE)
#' }
#'
#' try(g("exact"))               # Error: case not ignored
#' try(g("Exact"))               # "Exact"
#' try(g(c("Exact", "Partial"))) # "Exact", "Partial"
#' try(g(c("Exact", "Wrong")))   # "Exact"
#' try(g(c("Wrong1", "Wrong2"))) # Error: no match
#'
#' h <- function(z = NULL) {
#'   match_arg(z, c("None", "Exact", "Partial"),
#'             .context = "in {.fun h},")
#' }
#'
#' try(h("Wrong")) # Error with context

#' @export
match_arg <- function(x, choices, several.ok = FALSE, ignore.case = TRUE,
                      .context = NULL, .arg = rlang::caller_arg(x), .call) {
  arg_supplied(choices, .call = rlang::current_env())
  arg_character(choices, .call = rlang::current_env())

  arg_supplied(x, .arg = .arg, .call = .call)

  if (is_null(x)) {
    return(choices[1L])
  }

  arg_flag(several.ok, .call = rlang::current_env())
  arg_flag(ignore.case, .call = rlang::current_env())

  choices <- unique(choices)

  if (several.ok) {
    arg_character(x, .arg = .arg, .call = .call)
  }
  else {
    arg_string(x, .arg = .arg, .call = .call)
  }

  i <- pmatch(x, choices, nomatch = 0L,
              duplicates.ok = TRUE)

  if (ignore.case && any(i == 0)) {
    i[i == 0] <- pmatch(tolower(x[i == 0]), tolower(choices), nomatch = 0L,
                        duplicates.ok = TRUE)
  }

  if (all(i == 0L)) {
    one_of <- {
      if (length(choices) > 1L) {
        if (several.ok) "at least one of" else "one of"
      }
    }

    if (is_null(.context)) {
      err("{.arg {(.arg)}} should be {one_of} {.or {.val {choices}}}",
          .call = .call)
    }
    else {
      err(sprintf("%s {.arg {(.arg)}} should be {one_of} {.or {.val {choices}}}",
                  .context),
          .call = .call)
    }
  }

  i <- i[i > 0L]

  choices[i]
}
