# Check Supplied Dots Argument

Checks whether an argument was supplied to `...`.

## Usage

``` r
arg_dots_supplied(..., .msg = NULL)

arg_dots_not_supplied(..., .msg = NULL)
```

## Arguments

- ...:

  the `...` argument passed from a calling function. The argument is not
  evaluated. See Examples.

- .msg:

  an optional alternative message to display if an error is thrown
  instead of the default message.

## Value

Returns `NULL` invisibly if an error is not thrown.

## Details

`arg_dots_supplied()` checks whether arguments were passed to the `...`
(i.e., "dots") argument of a function. These arguments are not
evaluated. `arg_dots_supplied()` throws an error if
[`...length()`](https://rdrr.io/r/base/dots.html) is 0. It can be useful
for when a function must have additional arguments. For example,
[`arg_or()`](https://ngreifer.github.io/arg/reference/arg_or.md) and
[`when_supplied()`](https://ngreifer.github.io/arg/reference/when_supplied.md)
use `arg_dots_supplied()`.

`arg_dots_not_supplied()` checks whether no arguments were passed to
`...`, again without evaluating the arguments and using
[`...length()`](https://rdrr.io/r/base/dots.html). It can be useful when
a function appears to allow further arguments (e.g., because it is a
method of a generic), but when the author does not want the user to
supply them.

## See also

[`arg_supplied()`](https://ngreifer.github.io/arg/reference/arg_supplied.md)

## Examples

``` r
f <- function(...) {
  arg_dots_supplied(...)
}

try(f(1)) # No error: argument supplied
try(f())  # Error!
#> Error in f() : An argument must be supplied to `...`.
```
