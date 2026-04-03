# Check Common Argument Types

Checks whether an argument is an atomic vector (`arg_atomic()`), a
dimensionless atomic vector (`arg_vector()`), a
[`list`](https://rdrr.io/r/base/list.html) (`arg_list()`), a [data
frame](https://rdrr.io/r/base/data.frame.html) (`arg_data.frame()`), a
[`matrix`](https://rdrr.io/r/base/matrix.html) (`arg_matrix()`), an
[`array`](https://rdrr.io/r/base/array.html) (`arg_array()`), a
rectangular data set (`arg_data()`), or an
[`environment`](https://rdrr.io/r/base/environment.html) (`arg_env()`).

## Usage

``` r
arg_atomic(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_vector(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_list(x, df_ok = FALSE, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_data.frame(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_matrix(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_array(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_data(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_env(x, .arg = rlang::caller_arg(x), .msg = NULL, .call)
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

- df_ok:

  `logical`; whether to allow data frames (which are technically lists).
  Default is `FALSE` to throw an error on a data frame input.

## Value

Returns `NULL` invisibly if an error is not thrown.

## Details

Atomic vectors are checked using
[`is.atomic()`](https://rdrr.io/r/base/is.recursive.html). Because
matrices are considered atomic vectors, `arg_vector()` additionally
checks that there is no `"dims"` attribute, i.e., that
`length(dim(x)) == 0L`. `arg_data()` checks whether `x` is either a data
frame or a matrix. `arg_list()` checks whether `x` is a list; when
`df = FALSE`, it throws an error when `x` is a data frame, even though
data frames are lists.

## See also

[`is.atomic()`](https://rdrr.io/r/base/is.recursive.html),
[`is.list()`](https://rdrr.io/r/base/list.html),
[`is.data.frame()`](https://rdrr.io/r/base/as.data.frame.html),
[`is.matrix()`](https://rdrr.io/r/base/matrix.html),
[`is.array()`](https://rdrr.io/r/base/array.html),
[`is.environment()`](https://rdrr.io/r/base/environment.html),
[`arg_is()`](https://ngreifer.github.io/arg/reference/arg_is.md)

## Examples

``` r
vec <- 1:6
mat <- as.matrix(vec)
dat <- as.data.frame(mat)
lis <- as.list(vec)
nul <- NULL

# arg_atomic
try(arg_atomic(vec))
try(arg_atomic(mat))
try(arg_atomic(dat))
#> Error : `dat` must be an atomic vector.
try(arg_atomic(lis))
#> Error : `lis` must be an atomic vector.
try(arg_atomic(nul))
#> Error : `nul` must be an atomic vector.

# arg_vector
try(arg_vector(vec))
try(arg_vector(mat))
#> Error : `mat` must be a vector.

# arg_matrix
try(arg_matrix(vec))
#> Error : `vec` must be a matrix.
try(arg_matrix(mat))
try(arg_matrix(dat))
#> Error : `dat` must be a matrix.

# arg_data.frame
try(arg_data.frame(vec))
#> Error : `vec` must be a data frame.
try(arg_data.frame(mat))
#> Error : `mat` must be a data frame.
try(arg_data.frame(dat))

# arg_data
try(arg_data(vec))
#> Error : `vec` must be a data frame or matrix.
try(arg_data(mat))
try(arg_data(dat))
```
