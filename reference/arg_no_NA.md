# Check NA in Argument

Checks whether an argument does not contain any `NA` values
(`arg_no_NA()`), contains only `NA` values (`arg_all_NA()`), or is a
scalar `NA` (`arg_is_NA()`).

## Usage

``` r
arg_no_NA(x, .arg = rlang::caller_arg(x), .msg = NULL)

arg_is_NA(x, .arg = rlang::caller_arg(x), .msg = NULL)

arg_all_NA(x, .arg = rlang::caller_arg(x), .msg = NULL)
```

## Arguments

- x:

  the argument to be checked

- .arg:

  the name of the argument supplied to `x` to appear in error messages.
  The default is to extract the argument's name using
  [`rlang::caller_arg()`](https://rlang.r-lib.org/reference/caller_arg.html).
  Ignored if `.msg` is supplied.

- .msg:

  an optional alternative message to display if an error is thrown
  instead of the default message.

## Value

Returns `NULL` invisibly if an error is not thrown.

## Details

`arg_no_NA()` throws an error when `anyNA(x)` is `0`. `arg_all_NA()`
throws an error when `all(is.na(x))` is not `FALSE`. `arg_is_NA()`
throws an error when `length(x)` is not 1 or `anyNA(x)` is `FALSE`.

`arg_no_NA()` is useful for checking that a meaningful argument was
supplied. `arg_all_NA()` and `arg_is_NA()` are primarily used for in
[`arg_or()`](https://ngreifer.github.io/arg/reference/arg_or.md) to
denote that `NA` is an allowed argument.

## See also

[`arg_non_null()`](https://ngreifer.github.io/arg/reference/arg_non_null.md),
[`arg_supplied()`](https://ngreifer.github.io/arg/reference/arg_supplied.md),
[`anyNA()`](https://rdrr.io/r/base/NA.html)

## Examples

``` r
f <- function(x) {
  arg_no_NA(x)  ## x must not be NA
}

try(f(1))           ## No error
try(f(NA))          ## Error: x is NA
#> Error in f(NA) : `x` must not be NA.
try(f(c(1, NA, 3))) ## Error: x contains NA
#> Error in f(c(1, NA, 3)) : `x` must not contain NA values.

f2 <- function(y) {
  arg_all_NA(y) ## y must be NA
}

try(f2(NA))          ## No error
try(f2(c(NA, NA)))   ## No error
try(f2(1))           ## Error: y is not NA
#> Error in f2(1) : `y` must be NA.
try(f2(c(1, NA, 3))) ## Error: y is not all NA
#> Error in f2(c(1, NA, 3)) : 
#>   `y` must only contain NA values.
```
