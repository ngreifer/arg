# Check Numeric Argument

Checks whether an argument is numeric, with some additional constraints
if desired. `arg_numeric()` simply checks whether the argument is
numeric. `arg_number()` checks whether the argument is a numeric scalar
(i.e., a single number). `arg_whole_numeric()` and `arg_whole_number()`
check whether the argument is a whole numeric vector or scalar,
respectively. `arg_counts()` and `arg_count()` check whether the
argument is a non-negative whole numeric vector or scalar, respectively.

## Usage

``` r
arg_numeric(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_number(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_whole_numeric(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_whole_number(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_counts(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_count(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)
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

A whole number is decided by testing whether the value is an integer
(i.e., using [`is.integer()`](https://rdrr.io/r/base/integer.html)) or
if `abs(x - trunc(x)) < sqrt(.Machine$double.eps)`. This is the same
tolerance used by [`all.equal()`](https://rdrr.io/r/base/all.equal.html)
to compare values.

## See also

[`is.integer()`](https://rdrr.io/r/base/integer.html),
[`rlang::is_integerish()`](https://rlang.r-lib.org/reference/is_integerish.html)

## Examples

``` r
count <- 3
whole <- -4
num <- .943

try(arg_number(count))       # No error
try(arg_whole_number(count)) # No error
try(arg_count(count))        # No error

try(arg_number(whole))       # No error
try(arg_whole_number(whole)) # No error
try(arg_count(whole))        # Error: negatives not allowed
#> Error : `whole` must be a count (a non-negative whole number).

try(arg_number(num))       # No error
try(arg_whole_number(num)) # Error: not a whole number
#> Error : `num` must be a whole number.
try(arg_count(num))        # Error: not a count
#> Error : `num` must be a count (a non-negative whole number).

nums <- c(0, .5, 1)

try(arg_number(nums))  # Error: not a single number
#> Error : `nums` must be a single number.
try(arg_numeric(nums)) # No error
try(arg_counts(nums))  # Error: not counts
#> Error : `nums` must be a vector of counts (non-negative whole numeric values).
```
