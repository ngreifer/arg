# Check Named Argument

Checks whether an argument has valid (non-`NULL`, non-empty, and
non-`NA`) names.

## Usage

``` r
arg_named(x, .arg = rlang::caller_arg(x), .msg = NULL)

arg_colnamed(x, .arg = rlang::caller_arg(x), .msg = NULL)
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

`arg_named()` works for vectors, lists, and data frames. To check
whether a matrix has column names, use `arg_colnamed()` (which also
works for data frames, but not vectors or lists).

## See also

[`rlang::is_named()`](https://rlang.r-lib.org/reference/is_named.html),
[`names()`](https://rdrr.io/r/base/names.html),
[`colnames()`](https://rdrr.io/r/base/colnames.html),
[`arg_data()`](https://ngreifer.github.io/arg/reference/arg_data.md)

## Examples

``` r
obj <- c(1,
         B = 2,
         C = 3)

try(arg_named(obj)) # Error: one name is blank
#> Error in eval(expr, envir) : 
#>   `obj` must have non-empty and non-NA names.

names(obj)[1L] <- "A"
try(arg_named(obj)) # No error

obj2 <- unname(obj)
try(arg_named(obj2)) # Error: no names
#> Error in eval(expr, envir) : 
#>   `obj2` must have non-empty and non-NA names.

# Matrix and data frame
mat <- matrix(1:6, ncol = 2L)
colnames(mat) <- c("A", "B")

try(arg_named(mat))    # Error: matrices are not named
#> Error in eval(expr, envir) : 
#>   `mat` must have non-empty and non-NA names.
try(arg_colnamed(mat)) # No error

dat <- as.data.frame(mat)
try(arg_named(dat))    # No error: data frames are named
try(arg_colnamed(dat)) # No error

colnames(mat) <- NULL
try(arg_colnamed(mat)) # Error: no colnames
#> Error in eval(expr, envir) : 
#>   `mat` must have non-empty and non-NA names.
```
