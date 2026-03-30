# Throw an Error, Warning, or Message

These functions are similar to
[`stop()`](https://rdrr.io/r/base/stop.html)/[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html),
[`warning()`](https://rdrr.io/r/base/warning.html)/[`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html),
and
[`message()`](https://rdrr.io/r/base/message.html)/[`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html),
throwing an error, warning, and message, respectively. Minor processing
is done to capitalize the first letter of the message, add a period at
the end (if it makes sense to), and add information about the calling
function.

## Usage

``` r
err(m, .call, .envir = rlang::caller_env())

wrn(m, immediate = TRUE, .envir = rlang::caller_env())

msg(m, .envir = rlang::caller_env())
```

## Arguments

- m:

  the message to be displayed, passed to the `message` argument of
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html),
  [`rlang::warn()`](https://rlang.r-lib.org/reference/abort.html), or
  [`rlang::inform()`](https://rlang.r-lib.org/reference/abort.html).

- .call:

  the execution environment of a currently running function, e.g.
  `.call = rlang::current_env()`. The corresponding function call is
  retrieved and mentioned in error messages as the source of the error.
  See the `call` argument of
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) for
  details. Set to `NULL` to omit call information. The default is to
  search along the call stack for the first user-facing function in
  another package, if any.

- .envir:

  the environment to evaluate the glue expressions in. See
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) for
  details. Typically this does not need to be changed.

- immediate:

  whether to output the warning immediately (`TRUE`, the default) or
  save all warnings until the end of execution (`FALSE`). See
  [`warning()`](https://rdrr.io/r/base/warning.html) for details. Note
  that the default here differs from that of
  [`warning()`](https://rdrr.io/r/base/warning.html).

## Details

These functions are simple wrappers for the corresponding functions in
rlang, namely
[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) for
`err()`, [`rlang::warn()`](https://rlang.r-lib.org/reference/abort.html)
for `wrn()`, and
[`rlang::inform()`](https://rlang.r-lib.org/reference/abort.html) for
`msg()`, but which function almost identically to the cli versions.
Their main differences are that they additionally process the input
(capitalizing the first character of the message and adding a period to
the end if needed, unless multiple strings are provided). `err()` is
used inside all `arg_*()` functions in arg.

## See also

- Base versions: [`stop()`](https://rdrr.io/r/base/stop.html),
  [`warning()`](https://rdrr.io/r/base/warning.html),
  [`message()`](https://rdrr.io/r/base/message.html)

- rlang versions:
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html),
  [`rlang::warn()`](https://rlang.r-lib.org/reference/abort.html),
  [`rlang::inform()`](https://rlang.r-lib.org/reference/abort.html)

- cli versions:
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html),
  [`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html),
  [`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html)

## Examples

``` r
f <- function(x) {
  err("this is an error, and {.arg x} is {.type {x}}")
}

try(f(1))
#> Error : This is an error, and `x` is a number.

g <- function(x) {
  wrn("this warning displayed last", immediate = FALSE)
  wrn("this warning displayed first")
}

try(g(1))
#> Warning: This warning displayed last.
#> Warning: This warning displayed first.

h <- function() {
  msg("is a period added at the end?")
  msg("not when the message ends in punctuation!")
  msg(c("or when multiple",
        "!" = "messages",
        "v" = "are",
        "*" = "displayed"))
  msg("otherwise yes")
}

h()
#> Is a period added at the end?
#> Not when the message ends in punctuation!
#> or when multiple
#> ! messages
#> ✔ are
#> • displayed
#> Otherwise yes.
```
