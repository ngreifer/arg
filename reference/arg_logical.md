# Check Logical Argument

Checks whether an argument is a logical vector (`arg_logical()`) or a
logical scalar (`arg_flag()`), i.e., a single logical value. Logical
values include `TRUE` and `FALSE`.

## Usage

``` r
arg_logical(x, .arg = rlang::caller_arg(x), .msg = NULL)

arg_flag(x, .arg = rlang::caller_arg(x), .msg = NULL)
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

`NA` values in `arg_flag()` will cause an error to be thrown.

## See also

[`is.logical()`](https://rdrr.io/r/base/logical.html),
[`rlang::is_bool()`](https://rlang.r-lib.org/reference/scalar-type-predicates.html)

## Examples

``` r
obj <- TRUE

try(arg_flag(obj))    # No error
#> Error in eval(expr, envir) : 
#>   `obj` must be a logical value (TRUE or FALSE).
try(arg_logical(obj)) # No error

obj <- c(TRUE, FALSE)

try(arg_flag(obj))    # Error: must be a scalar
#> Error in eval(expr, envir) : 
#>   `obj` must be a logical value (TRUE or FALSE).
try(arg_logical(obj)) # No error

obj <- 1L

try(arg_flag(obj))    # Error must be logical
#> Error in eval(expr, envir) : 
#>   `obj` must be a logical value (TRUE or FALSE).
try(arg_logical(obj)) # Error must be logical
#> Error in eval(expr, envir) : `obj` must be a logical vector.
```
