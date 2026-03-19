# Check Symmetric Matrix Argument

`arg_symmetric()` checks whether an argument is a square, symmetric,
numeric matrix. `arg_cov()` checks whether an argument is like a
covariance matrix (i.e., square and symmetric with non-negative diagonal
entries). `arg_cor()` checks whether an argument is like a correlation
matrix (i.e., square and symmetric with all values between -1 and 1 and
ones on the diagonal). `arg_distance()` checks whether an argument is
like a distance matrix (i.e., square and symmetric with non-negative
entries and zeros on the diagonal).

## Usage

``` r
arg_symmetric(
  x,
  tol = 100 * .Machine$double.eps,
  ...,
  .arg = rlang::caller_arg(x),
  .msg = NULL
)

arg_cov(
  x,
  tol = 100 * .Machine$double.eps,
  ...,
  .arg = rlang::caller_arg(x),
  .msg = NULL
)

arg_cor(
  x,
  tol = 100 * .Machine$double.eps,
  ...,
  .arg = rlang::caller_arg(x),
  .msg = NULL
)

arg_distance(
  x,
  tol = 100 * .Machine$double.eps,
  ...,
  .arg = rlang::caller_arg(x),
  .msg = NULL
)
```

## Arguments

- x:

  the argument to be checked

- tol:

  `numeric`; the tolerance value used to assess symmetry and any
  numerical bounds. Passed to
  [`isSymmetric()`](https://rdrr.io/r/base/isSymmetric.html).

- ...:

  other arguments passed to
  [`isSymmetric()`](https://rdrr.io/r/base/isSymmetric.html) (and
  eventually to [`all.equal()`](https://rdrr.io/r/base/all.equal.html)).

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

These functions check that an argument is a square, symmetric, numeric
matrix. This can be useful when a function can accept a covariance
matrix, correlation matrix, or distance matrix. `arg_cov()` will throw
an error if any values on its diagonal are less than `-tol`. `arg_cor()`
will throw an error if any of its values are greater than `1 + tol` in
absolute value or if the diagonal entries are not between `-1 - tol` and
`1 + tol`. `arg_distance()` will thrown an error if any of its values
are less than `-tol` or if the diagonal entries are not between `-tol`
and `tol`. The tolerance is just slightly greater than 0 to allow for
numeric imprecision.

No checks on semi-definiteness or rank are performed.

## See also

[`arg_numeric()`](https://ngreifer.github.io/arg/reference/arg_numeric.md),
[`arg_matrix()`](https://ngreifer.github.io/arg/reference/arg_data.md),
[`arg_between()`](https://ngreifer.github.io/arg/reference/arg_between.md),
[`isSymmetric()`](https://rdrr.io/r/base/isSymmetric.html)

## Examples

``` r
set.seed(1234)
mat <- matrix(rnorm(12), ncol = 3L) # Non square
sym_mat <- -crossprod(mat)          # Square, symmetric
cov_mat <- cov(mat)                 # Covariance
cor_mat <- cor(mat)                 # Correlation
dist_mat <- as.matrix(dist(mat))    # Distance

try(arg_symmetric(mat))     # Error: not square
#> Error in eval(expr, envir) : 
#>   `mat` must be a square, symmetric, numeric matrix.
try(arg_symmetric(sym_mat)) # No error

try(arg_cov(sym_mat)) # Error: diagonal must be non-negative
#> Error in eval(expr, envir) : 
#>   `sym_mat` must be a square, symmetric matrix with non-negative values on
#> the diagonal.
try(arg_cov(cov_mat)) # No error

try(arg_cor(cov_mat)) # Error: values must be in [-1, 1]
#> Error in eval(expr, envir) : 
#>   All values in `cov_mat` must be between -1 and 1.
try(arg_cor(cor_mat)) # No error

try(arg_distance(cor_mat))  # Error: diagonal must be 0
#> Error in eval(expr, envir) : 
#>   `cor_mat` must be a square, symmetric matrix with zeros on the diagonal.
try(arg_distance(dist_mat)) # No error
```
