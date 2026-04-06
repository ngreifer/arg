# Check Argument Length

Checks whether an argument has a specified length.

## Usage

``` r
arg_length(x, len = 1L, .arg = rlang::caller_arg(x), .msg = NULL, .call)
```

## Arguments

- x:

  the argument to be checked

- len:

  `integer`; the allowed length(s) of `x`. Default is 1.

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

`len` can contain multiple allowed counts; an error will be thrown only
if `length(x)` is not equal to any value of `len`.

## See also

[`length()`](https://rdrr.io/r/base/length.html),
[`arg_non_null()`](https://ngreifer.github.io/arg/reference/arg_non_null.md)
to specifically test that an object's length is or is not 0.

## Examples

``` r
obj <- 1:4

try(arg_length(obj, 1))
#> Error : `obj` must have length 1.
try(arg_length(obj, 4))
try(arg_length(obj, c(1, 4)))

# These test the same thing:
try(arg_length(obj, c(0:3)))
#> Error : `obj` must have length 0, 1, 2, or 3.
try(when_not_null(obj,
                  arg_length(1:3)))
#> Error : When `obj` is not NULL, `obj` must have length 1, 2, or 3.
```
