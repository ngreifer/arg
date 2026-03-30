# Check Index Argument

Checks whether an argument is a valid column index (`arg_index()`) of a
data set or a vector thereof (`arg_indices()`).

## Usage

``` r
arg_index(
  x,
  data,
  .arg = rlang::caller_arg(x),
  .arg_data = rlang::caller_arg(data),
  .msg = NULL,
  .call
)

arg_indices(
  x,
  data,
  .arg = rlang::caller_arg(x),
  .arg_data = rlang::caller_arg(data),
  .msg = NULL,
  .call
)
```

## Arguments

- x:

  the argument to be checked

- data:

  a data set (i.e., a matrix or data frame)

- .arg:

  the name of the argument supplied to `x` to appear in error messages.
  The default is to extract the argument's name using
  [`rlang::caller_arg()`](https://rlang.r-lib.org/reference/caller_arg.html).
  Ignored if `.msg` is supplied.

- .arg_data:

  the name of the argument supplied to `data` to appear in error
  messages. The default is to extract the argument's name using
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

For `arg_indices()`, an error will be thrown unless one of the following
are true:

- `x` is a vector of counts (see
  [`arg_counts()`](https://ngreifer.github.io/arg/reference/arg_numeric.md))
  less than or equal to `ncol(data)`

- `x` is a character vector with values a subset of `colnames(data)`

For `arg_index()`, `x` additionally must have length equal to 1. Passing
`arg_index()` ensures that `data[, x]` (if `data` is a matrix) or
`data[[x]]` (if `x` is a data frame) evaluate correctly.

If `data` has no column names, an error will be thrown if `x` is a
character vector.

## See also

[`arg_counts()`](https://ngreifer.github.io/arg/reference/arg_numeric.md),
[`arg_character()`](https://ngreifer.github.io/arg/reference/arg_character.md)

## Examples

``` r
dat <- data.frame(col1 = 1:5,
                  col2 = 6:10)

f <- function(z) {
  arg_index(z, dat)
}

try(f(1))         # No error
try(f(3))         # Error: not a valid index
#> Error : `z` must be the name or index of a column in `dat`.
try(f("col1"))    # No error
try(f("bad_col")) # Error: not a valid index
#> Error : `z` must be the name or index of a column in `dat`.
try(f(1:2))       # Error: arg_index() requires scalar
#> Error : `z` must be the name or index of a column in `dat`.

mat <- matrix(1:9, ncol = 3)

g <- function(z) {
  arg_indices(z, mat)
}

try(g(1))     # No error
try(g(1:3))   # No error
try(g("col")) # Error: `mat` has no names
#> Error : `z` must be the index of a column in `mat`.
```
