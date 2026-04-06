# Check Arguments When Supplied

These functions check arguments only when they are supplied
(`when_supplied()`) or when not `NULL` (`when_not_null()`). Multiple
checks can be applied in sequence. This allows arguments not to have to
be supplied, but checks them only if they are.

## Usage

``` r
when_supplied(x, ..., .arg = rlang::caller_arg(x), .call)

when_not_null(x, ..., .arg = rlang::caller_arg(x), .call)
```

## Arguments

- x:

  the argument to be checked

- ...:

  `arg_*()` functions or unevaluated function calls to be applied to
  `x`. See Examples.

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

Returns `NULL` invisibly if an error is not thrown.

## Details

An error will be thrown only if `x` is supplied and fails one of the
supplied checks (`when_supplied()`) or is not `NULL` and fails one of
the supplied checks (`when_not_null()`).

The `...` arguments can be passed either as functions, e.g.,

    when_supplied(x,
                  arg_number,
                  arg_gt)

or as unevaluated function calls with the `x` argument absent, e.g.,

    when_supplied(x,
                  arg_number(),
                  arg_gt(bound = 0))

or as a mixture of both.

`when_supplied()` only makes sense to use for an argument that has no
default value but which can be omitted. `when_not_null()` makes sense to
use for an argument with a default value of `NULL`.

## See also

[`arg_or()`](https://ngreifer.github.io/arg/reference/arg_or.md),
[`arg_supplied()`](https://ngreifer.github.io/arg/reference/arg_supplied.md)

## Examples

``` r
f <- function(z) {
  when_supplied(z,
                arg_number,
                arg_between(c(0, 1)))
}

try(f())    # No error: not supplied
try(f("a")) # Error: not a number
#> Error : When `z` is supplied, `z` must be a number.
try(f(2))   # Error: not within 0-1 range
#> Error : When `z` is supplied, `z` must be between 0 and 1 (inclusive).
try(f(.7))  # No error: number within range

g <- function(z = NULL) {
  when_not_null(z,
                arg_number,
                arg_between(c(0, 1)))
}

try(g())     # No error: NULL okay
try(g(NULL)) # No error: NULL okay
try(g("a"))  # Error: not a number
#> Error : When `z` is not NULL, `z` must be a number.
try(g(2))    # Error: not within 0-1 range
#> Error : When `z` is not NULL, `z` must be between 0 and 1 (inclusive).
try(g(.7))   # No error: number within range
```
