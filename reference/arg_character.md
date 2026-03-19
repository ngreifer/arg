# Check Character Argument

Checks whether an argument is a character vector (`arg_character()`), a
character scalar (`arg_string()`), or a factor (`arg_factor()`).

## Usage

``` r
arg_character(x, .arg = rlang::caller_arg(x), .msg = NULL)

arg_string(x, .arg = rlang::caller_arg(x), .msg = NULL)

arg_factor(x, .arg = rlang::caller_arg(x), .msg = NULL)
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

`NA` values in `arg_string()` will cause an error to be thrown.

## See also

[`is.character()`](https://rdrr.io/r/base/character.html),
[`is.factor()`](https://rdrr.io/r/base/factor.html),
[`rlang::is_string()`](https://rlang.r-lib.org/reference/scalar-type-predicates.html)

## Examples

``` r
f <- function(z) {
  arg_string(z)
}

try(f("a")) # No error
try(f(c("a", "b"))) # Error: arg_string() requires scalar
#> Error in f(c("a", "b")) : `z` must be a string.
try(f(NA)) # NAs not allowed for arg_string()
#> Error in f(NA) : `z` must be a string.
```
