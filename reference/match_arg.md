# Argument Verification

An alternative to [`match.arg()`](https://rdrr.io/r/base/match.arg.html)
with improved error messages via cli. Returns the first choice if `x` is
`NULL`, and supports partial matching.

## Usage

``` r
match_arg(
  x,
  choices,
  several.ok = FALSE,
  ignore.case = TRUE,
  .context = NULL,
  .arg = rlang::caller_arg(x),
  .call
)
```

## Arguments

- x:

  a string (or character vector if `several.ok = TRUE`) to match against
  `choices`. If `NULL`, the first element of `choices` is returned.

- choices:

  a character vector of valid values.

- several.ok:

  `logical`; if `TRUE`, `x` may contain more than one element. Defaults
  to `FALSE`.

- ignore.case:

  `logical`; if `FALSE`, the matching is case sensitive, and if `TRUE`
  (the default), case is ignored.

- .context:

  an optional character string providing context for error messages
  (e.g., a function or object name). Prepended to the error message when
  supplied before being evaluated by cli.

- .arg:

  the name of the argument supplied to `x` to appear in error messages.
  The default is to extract the argument's name using
  [`rlang::caller_arg()`](https://rlang.r-lib.org/reference/caller_arg.html).
  Ignored if `.msg` is supplied.

- .call:

  the execution environment of a currently running function, e.g.
  `.call = rlang::current_env()`. The corresponding function call is
  retrieved and mentioned in error messages as the source of the error.
  Passed to [`err()`](https://ngreifer.github.io/arg/reference/err.md).
  Set to `NULL` to omit call information. The default is to search along
  the call stack for the first user-facing function in another package,
  if any.

## Value

A character string (or vector, if `several.ok = TRUE`) of the matched
element(s) from `choices`. If there is no match, an error is thrown.
When `several.ok = TRUE`, no error is thrown if there is at least one
match.

## Details

Partial matching is supported via
[`pmatch()`](https://rdrr.io/r/base/pmatch.html). If no match is found,
an error is thrown listing the valid `choices`.

Checks are run on `x` prior to matching: first,
[`arg_supplied()`](https://ngreifer.github.io/arg/reference/arg_supplied.md)
is used to check whether `x` was supplied; then
[`arg_string()`](https://ngreifer.github.io/arg/reference/arg_character.md)
(if `several.ok = TRUE`) or
[`arg_character()`](https://ngreifer.github.io/arg/reference/arg_character.md)
(if `several.ok = FALSE`) is used to check whether `x` is a valid string
or character vector, respectively.

When `ignore.case = TRUE` (the default), an initial case-sensitive match
is run, and if any values in `x` are unmatched, a second,
case-insensitive match is run. When `ignore.case = FALSE`, only the
first match is run. This ensures that exact matches (on both content and
case) are prioritized before case-insensitive matches.

## See also

- [`match.arg()`](https://rdrr.io/r/base/match.arg.html) for the base R
  version

- [`pmatch()`](https://rdrr.io/r/base/pmatch.html) for the function
  implementing partial string matching

- [`arg_element()`](https://ngreifer.github.io/arg/reference/arg_element.md)
  for a version without type checking and that doesn't support partial
  matching

- [`rlang::arg_match()`](https://rlang.r-lib.org/reference/arg_match.html)
  for a similar rlang function that doesn't support partial matching.

## Examples

``` r
f <- function(z = NULL) {
  match_arg(z, c("None", "Exact", "Partial"),
            ignore.case = TRUE)
}

try(f())            # "None" (first choice returned)
#> [1] "None"
try(f("partial"))   # "Partial"
#> [1] "Partial"
try(f("p"))         # "Partial" (partial match)
#> [1] "Partial"
try(f(c("e", "p"))) # Error: several.ok = FALSE
#> Error : `z` must be a string.

# several.ok = TRUE
g <- function(z = NULL) {
  match_arg(z, c("None", "Exact", "Partial"),
            several.ok = TRUE)
}

try(g("exact"))               # Error: case not ignored
#> [1] "Exact"
try(g("Exact"))               # "Exact"
#> [1] "Exact"
try(g(c("Exact", "Partial"))) # "Exact", "Partial"
#> [1] "Exact"   "Partial"
try(g(c("Exact", "Wrong")))   # "Exact"
#> [1] "Exact"
try(g(c("Wrong1", "Wrong2"))) # Error: no match
#> Error : `z` should be at least one of "None", "Exact", or "Partial".

h <- function(z = NULL) {
  match_arg(z, c("None", "Exact", "Partial"),
            .context = "in {.fun h},")
}

try(h("Wrong")) # Error with context
#> Error : In `h()`, `z` should be one of "None", "Exact", or "Partial".
```
