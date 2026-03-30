# Check Element

Checks whether values in an argument are all elements of some set
(`arg_element()`) or are not all elements of a set
(`arg_not_element()`). `arg_element()` throws an error when
`all(is.element(x, values))` is `FALSE`, and `arg_not_element()` throws
an error when `any(is.element(x, values))` is `TRUE`.

## Usage

``` r
arg_element(x, values, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_not_element(x, values, .arg = rlang::caller_arg(x), .msg = NULL, .call)
```

## Arguments

- x:

  the argument to be checked

- values:

  the values to check `x` against.

- .arg:

  the name of the argument supplied to `x` to appear in error messages.
  The default is to extract the argument's name using
  [`rlang::caller_arg()`](https://rlang.r-lib.org/reference/caller_arg.html).
  Ignored if `.msg` is supplied.

- .msg:

  an optional alternative message to display if an error is thrown
  instead of the default message.

- .call:

  the execution environment of a currently running function, e.g.
  `.call = rlang::current_env()`. The corresponding function call is
  retrieved and mentioned in error messages as the source of the error.
  Passed to [`err()`](https://ngreifer.github.io/arg/reference/err.md).
  Set to `NULL` to omit call information. The default is to search along
  the call stack for the first user-facing function in another package,
  if any.

## Value

Returns `NULL` invisibly if an error is not thrown.

## Details

`arg_element()` can be useful for checking whether an argument matches
one or more allowed values. It's important that a check is done
beforehand to ensure `x` is the correct type, e.g., using
[`arg_string()`](https://ngreifer.github.io/arg/reference/arg_character.md)
or
[`arg_character()`](https://ngreifer.github.io/arg/reference/arg_character.md)
if `values` is a character vector. No partial matching is used; the
values must match exactly. Use
[`match_arg()`](https://ngreifer.github.io/arg/reference/match_arg.md)
to allow partial matching and return the full version of the supplied
argument.

`arg_not_element()` can be useful for ensuring there is no duplication
of values between an argument and some other set.

## See also

[`is.element()`](https://rdrr.io/r/base/sets.html),
[`match_arg()`](https://ngreifer.github.io/arg/reference/match_arg.md)

## Examples

``` r
f <- function(z) {
  arg_element(z, c("opt1", "opt2", "opt3"))
}

try(f("opt1"))            # No error
try(f(c("opt1", "opt2"))) # No error, all are elements
try(f(c("opt1", "opt1"))) # No error: repeats allowed
try(f("bad_arg"))         # Error: not an element of set
#> Error : `z` must be one of "opt1", "opt2", or "opt3".
try(f("opt"))             # Error: partial matching not allowed
#> Error : `z` must be one of "opt1", "opt2", or "opt3".
try(f(c("opt1", "bad_arg"))) # Error: one non-match
#> Error : Each element of `z` must be one of "opt1", "opt2", or "opt3".

g <- function(z) {
  arg_not_element(z, c("bad1", "bad2", "bad3"))
}

try(g("bad1"))            # Error: z is an element
#> Error : `z` must not be one of "bad1", "bad2", or "bad3".
try(g(c("bad1", "opt2"))) # Error: at least one bad match
#> Error : No element of `z` may be one of "bad1", "bad2", or "bad3".
try(g("opt1"))            # No error: not an element
try(g(c("opt1", "opt2"))) # No error, none are elements
```
