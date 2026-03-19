# Check Values in Range

Checks whether values are within a range (`arg_between()`), greater than
some value (`arg_gt()`), greater than or equal to some value
(`arg_gte()`), less than some value (`arg_lt()`), or less than or equal
to some value (`arg_lte()`).

## Usage

``` r
arg_between(
  x,
  range = c(0, 1),
  inclusive = TRUE,
  .arg = rlang::caller_arg(x),
  .msg = NULL
)

arg_gt(x, bound = 0, .arg = rlang::caller_arg(x), .msg = NULL)

arg_gte(x, bound = 0, .arg = rlang::caller_arg(x), .msg = NULL)

arg_lt(x, bound = 0, .arg = rlang::caller_arg(x), .msg = NULL)

arg_lte(x, bound = 0, .arg = rlang::caller_arg(x), .msg = NULL)
```

## Arguments

- x:

  the argument to be checked

- range:

  a vector of two values identifying the required range.

- inclusive:

  a logical vector identifying whether the range boundaries are
  inclusive or not. If only one value is supplied, it is applied to both
  range boundaries. Default is `TRUE`, which will not throw an error if
  `x` is equal to the boundaries.

- .arg:

  the name of the argument supplied to `x` to appear in error messages.
  The default is to extract the argument's name using
  [`rlang::caller_arg()`](https://rlang.r-lib.org/reference/caller_arg.html).
  Ignored if `.msg` is supplied.

- .msg:

  an optional alternative message to display if an error is thrown
  instead of the default message.

- bound:

  the bound to check against. Default is 0.

## Value

Returns `NULL` invisibly if an error is not thrown.

## Details

`x` is not checked for type, as it is possible for values other than
numeric values to be passed and compared; however, an error will be
thrown if `typeof(x)` is not equal to `typeof(range)` or
`typeof(bound)`. `NA` values of `x` will be removed. The arguments to
`range`, `inclusive`, and `bound` are checked for appropriateness.

## Examples

``` r
z <- 2

try(arg_between(z, c(1, 3))) # No error
try(arg_between(z, c(1, 2))) # No error
try(arg_between(z, c(1, 2),
                inclusive = FALSE)) # Error
#> Error in eval(expr, envir) : 
#>   `z` must be between 1 and 2 (exclusive).
try(arg_between(z, c(1, 2),
                inclusive = c(TRUE, FALSE))) # Error
#> Error in eval(expr, envir) : 
#>   `z` must be greater than or equal to 1 and less than 2.

try(arg_gt(z, 0))  # No error
try(arg_gt(z, 2))  # Error
#> Error in eval(expr, envir) : `z` must be greater than 2.
try(arg_gte(z, 2)) # No error

try(arg_lt(z, 0))  # Error
#> Error in eval(expr, envir) : `z` must be negative.
try(arg_lt(z, 2))  # Error
#> Error in eval(expr, envir) : `z` must be less than 2.
try(arg_lte(z, 2)) # No error

try(arg_lte(z, "3")) # Error: wrong type
#> Error in eval(expr, envir) : 
#>   `z` must be less than or equal to "3".
```
