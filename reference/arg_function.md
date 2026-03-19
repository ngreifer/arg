# Check Function Argument

Checks whether an argument is a function.

## Usage

``` r
arg_function(x, .arg = rlang::caller_arg(x), .msg = NULL)
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

[`rlang::is_function()`](https://rlang.r-lib.org/reference/is_function.html),
[`arg_is()`](https://ngreifer.github.io/arg/reference/arg_is.md)

## Examples

``` r
f <- function(z) {
  arg_function(z)
}

try(f(print))   # No error
try(f("print")) # Error: must be a function
#> Error in f("print") : `z` must be a function.
```
