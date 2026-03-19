# Check Unique Argument

Checks whether an argument contains only unique values.

## Usage

``` r
arg_unique(x, ..., .arg = rlang::caller_arg(x), .msg = NULL)
```

## Arguments

- x:

  the argument to be checked

- ...:

  further argument passed to
  [`anyDuplicated()`](https://rdrr.io/r/base/duplicated.html), which
  performs the checking.

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

[`anyDuplicated()`](https://rdrr.io/r/base/duplicated.html)

## Examples

``` r
f <- function(z) {
  arg_unique(z)
}

try(f(1:3))     # No error
try(f(NULL))    # No error for NULL
try(f(c(1, 1))) # Error: repeated values
#> Error in f(c(1, 1)) : `z` must only contain unique values.
```
