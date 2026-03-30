# Check Logical Argument

Checks whether an argument is a logical vector (`arg_logical()`) or a
logical scalar (`arg_flag()`), i.e., a single logical value. Logical
values include `TRUE` and `FALSE`.

## Usage

``` r
arg_logical(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_flag(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)
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

`NA` values in `arg_flag()` will cause an error to be thrown.

## See also

[`is.logical()`](https://rdrr.io/r/base/logical.html),
[`rlang::is_bool()`](https://rlang.r-lib.org/reference/scalar-type-predicates.html)

## Examples

``` r
obj <- TRUE

try(arg_flag(obj))    # No error
try(arg_logical(obj)) # No error

obj <- c(TRUE, FALSE)

try(arg_flag(obj))    # Error: must be a scalar
#> Error : `obj` must be a single logical value (TRUE or FALSE).
try(arg_logical(obj)) # No error

obj <- 1L

try(arg_flag(obj))    # Error must be logical
#> Error : `obj` must be a logical value (TRUE or FALSE).
try(arg_logical(obj)) # Error must be logical
#> Error : `obj` must be a logical vector.
```
