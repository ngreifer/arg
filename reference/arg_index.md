# Check Index Argument

Checks whether an argument is a valid column index or name
(`arg_index()`) of a dataset or a vector of valid column indices or
names (`arg_indices()`). `arg_name()` and `arg_names()` additionally
require that the argument is a string or character, respectively.

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

arg_name(
  x,
  data,
  .arg = rlang::caller_arg(x),
  .arg_data = rlang::caller_arg(data),
  .msg = NULL,
  .call
)

arg_names(
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

  a dataset (i.e., a matrix or data frame) or other vector-like object.

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
  less than or equal to `ncol(data)` (or `length(data)` if `data` is not
  a dataset)

- `x` is a character vector with values a subset of `colnames(data)` (or
  `names(data)` if `data` is not a dataset)

For `arg_index()`, `x` additionally must have length equal to 1. Passing
`arg_index()` ensures that `data[, x]` (if `data` is a matrix) or
`data[[x]]` (otherwise) evaluate correctly. For `arg_name()` and
`arg_names()`, an error will be thrown unless `x` is additionally a
string or character vector, respectively.

If `data` is a dataset with no column names or otherwise has no names,
an error will be thrown if `x` is a character vector.

## See also

[`arg_counts()`](https://ngreifer.github.io/arg/reference/arg_numeric.md),
[`arg_character()`](https://ngreifer.github.io/arg/reference/arg_character.md)

[`arg_named()`](https://ngreifer.github.io/arg/reference/arg_named.md)
for checking whether a dataset or other object has names.

## Examples

``` r
dat <- data.frame(col1 = 1:5,
                  col2 = 6:10)

f1 <- function(z) {
  arg_index(z, dat)
}

try(f1(1))         # No error
try(f1(3))         # Error: not a valid index
#> Error : `z` must be the name or index of a column in `dat`.
try(f1("col1"))    # No error
try(f1("bad_col")) # Error: not a valid index
#> Error : `z` must be the name or index of a column in `dat`.
try(f1(1:2))       # Error: arg_index() requires scalar
#> Error : `z` must be the name or index of a column in `dat`.

f2 <- function(z) {
  arg_name(z, dat)
}


try(f2("col1"))            # No error
try(f2(1))                 # Error: not a string
#> Error : `z` must be the name of a column in `dat`.
try(f2("bad_col"))         # Error: not a valid name
#> Error : `z` must be the name of a column in `dat`.
try(f2(c("col1", "col2"))) # Error: arg_name() requires scalar
#> Error : `z` must be the name of a column in `dat`.

mat <- matrix(1:9, ncol = 3)

g <- function(z) {
  arg_indices(z, mat)
}

try(g(1))     # No error
try(g(1:3))   # No error
try(g("col")) # Error: `mat` has no names
#> Error : `z` must be the index of a column in `mat`.
```
