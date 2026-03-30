# Check Equal Arguments

Checks whether two arguments are equal (`arg_equal()`) or not equal
(`arg_not_equal()`).

## Usage

``` r
arg_equal(
  x,
  x2,
  ...,
  .arg = rlang::caller_arg(x),
  .arg2 = rlang::caller_arg(x2),
  .msg = NULL,
  .call
)

arg_not_equal(
  x,
  x2,
  ...,
  .arg = rlang::caller_arg(x),
  .arg2 = rlang::caller_arg(x2),
  .msg = NULL,
  .call
)
```

## Arguments

- x, x2:

  the objects to compare with each other.

- ...:

  other arguments passed to
  [`all.equal()`](https://rdrr.io/r/base/all.equal.html).

- .arg, .arg2:

  the names of the objects being compared; used in the error message if
  triggered. Ignored if `.msg` is supplied.

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

Tests for equality are performed by evaluating whether
`isTRUE(all.equal(x, x2, ...))` is `TRUE` or `FALSE`.

## See also

[`all.equal()`](https://rdrr.io/r/base/all.equal.html)

## Examples

``` r
f <- function(x, y, ...) {
  arg_equal(x, y, ...)
}

try(f(x = 1, y = 1))      ## No error
try(f(x = 1L, y = 1.0))   ## No error despite type difference
try(f(x = 1, y = 1.00001, ## No error, within tolerance
      tolerance = .001))

try(f(x = 1, y = 2))       ## Error: different
#> Error : `x` must be equal to `y`.
try(f(x = 1, y = 1.00001)) ## Error
#> Error : `x` must be equal to `y`.

g <- function(x, y, ...) {
  arg_not_equal(x, y, ...)
}

try(g(x = 1, y = 1)) ## Error
#> Error : `x` must not be equal to `y`.
try(g(x = 1, y = 2)) ## No error
```
