# Check Supplied Argument

Checks whether an argument with no default value was supplied. An error
will be thrown if `rlang::is_missing(x)` is `TRUE`, i.e., if an argument
with no default is omitted from a function call.

## Usage

``` r
arg_supplied(x, .arg = rlang::caller_arg(x), .msg = NULL)
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

## See also

[`arg_non_null()`](https://ngreifer.github.io/arg/reference/arg_non_null.md),
[`arg_no_NA()`](https://ngreifer.github.io/arg/reference/arg_no_NA.md),
[`rlang::is_missing()`](https://rlang.r-lib.org/reference/missing_arg.html),
[`rlang::check_required()`](https://rlang.r-lib.org/reference/check_required.html)

## Examples

``` r
f <- function(z) {
  arg_supplied(z)
}

try(f(1)) ## No error: argument supplied
try(f())  ## Error!
#> Error in f() : An argument to `z` must be supplied.

# Will not throw for NULL or default arguments
try(f(NULL)) ## No error: argument supplied

f2 <- function(z = NULL) {
  arg_supplied(z)
}

try(f2()) ## No error; default provided
```
