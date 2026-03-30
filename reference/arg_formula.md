# Check Formula Argument

Checks whether an argument is a
[`formula`](https://rdrr.io/r/stats/formula.html).

## Usage

``` r
arg_formula(
  x,
  one_sided = NULL,
  .arg = rlang::caller_arg(x),
  .msg = NULL,
  .call
)
```

## Arguments

- x:

  the argument to be checked

- one_sided:

  `NULL` or `logical`; if `TRUE`, checks that `x` is a `formula` with
  only one side (the right side); if `FALSE`, checks that `x` is a
  `formula` with both sides; if `NULL` (the default), checks only that
  `x` is a `formula.`

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

## See also

[`rlang::is_formula()`](https://rlang.r-lib.org/reference/is_formula.html),
[`arg_is()`](https://ngreifer.github.io/arg/reference/arg_is.md)

## Examples

``` r
form1 <- ~a + b
form2 <- y ~ a + b
not_form <- 1:3

try(arg_formula(form1))    # No error
try(arg_formula(form2))    # No error
try(arg_formula(not_form)) # Error: not a formula
#> Error : `not_form` must be a formula.

try(arg_formula(form1,
                one_sided = TRUE)) # No error
try(arg_formula(form2,
                one_sided = TRUE)) # Error, not one-sided
#> Error : `form2` must be a one-sided formula.

try(arg_formula(form1,
                one_sided = FALSE)) # Error, only one-sided
#> Error : `form1` must be a two-sided formula.
try(arg_formula(form2,
                one_sided = FALSE)) # No error
```
