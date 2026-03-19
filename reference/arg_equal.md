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
  .msg = NULL
)

arg_not_equal(
  x,
  x2,
  ...,
  .arg = rlang::caller_arg(x),
  .arg2 = rlang::caller_arg(x2),
  .msg = NULL
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
#> Error in f(x = 1, y = 2) : `x` must be equal to `y`.
try(f(x = 1, y = 1.00001)) ## Error
#> Error in f(x = 1, y = 1.00001) : `x` must be equal to `y`.

g <- function(x, y, ...) {
  arg_not_equal(x, y, ...)
}

try(g(x = 1, y = 1)) ## Error
#> Error in g(x = 1, y = 1) : `x` must not be equal to `y`.
try(g(x = 1, y = 2)) ## No error
```
