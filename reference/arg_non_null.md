# Check NULL Argument

Checks whether an argument is non-`NULL` (`arg_non_null()`) or is `NULL`
(`arg_null()`). `arg_non_null()` throws an error when `length(x)` is
`0`. `arg_null()` throws an error when `length(x)` is not `0`.

## Usage

``` r
arg_non_null(x, .arg = rlang::caller_arg(x), .msg = NULL)

arg_null(x, .arg = rlang::caller_arg(x), .msg = NULL)
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

Here, `NULL` refers to any length-0 object, including `NULL`,
`logical(0L)`, [`list()`](https://rdrr.io/r/base/list.html), `3[FALSE]`,
etc. `arg_non_null()` is useful for checking that a meaningful argument
was supplied. `arg_null()` is primarily used for in
[`arg_or()`](https://ngreifer.github.io/arg/reference/arg_or.md) to
denote that `NULL` is an allowed argument.

## See also

[`arg_length()`](https://ngreifer.github.io/arg/reference/arg_length.md),
[`arg_no_NA()`](https://ngreifer.github.io/arg/reference/arg_no_NA.md),
[`arg_supplied()`](https://ngreifer.github.io/arg/reference/arg_supplied.md)

## Examples

``` r
f <- function(x = NULL, y = NULL) {
  arg_non_null(x) ## x must not be NULL
  arg_null(y)     ## y must be NULL
}

try(f(x = 1,    y = NULL)) ## No error
try(f(x = NULL, y = NULL)) ## Error: x is NULL
#> Error in f(x = NULL, y = NULL) : `x` must be non-NULL.
try(f(x = 1,    y = 1))    ## Error: y is non-NULL
#> Error in f(x = 1, y = 1) : `y` must be NULL.

# Any object of length 0 is considered NULL
try(f(x = numeric())) ## Error: x is NULL
#> Error in f(x = numeric()) : `x` must be non-NULL.
try(f(x = list()))    ## Error: x is NULL
#> Error in f(x = list()) : `x` must be non-NULL.

test <- c(1, 2)[c(FALSE, FALSE)]
try(f(x = test))      ## Error: x is NULL
#> Error in f(x = test) : `x` must be non-NULL.

# arg_null() is best used in and_or():
f2 <- function(z) {
  arg_or(z,
         arg_null(),
         arg_number())
}

try(f2(NULL)) ## No error; z can be NULL
try(f2(1))    ## No error; z can be a number
try(f2(TRUE)) ## Error: z must be NULL or a number
#> Error in f2(TRUE) : `z` must be NULL or a number.
```
