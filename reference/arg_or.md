# Check That Arguments Meet Some or All Criteria

`arg_or()` checks whether an argument meets at least one given
criterion. `arg_and()` checks whether an argument meets all given
criteria.

## Usage

``` r
arg_or(x, ..., .arg = rlang::caller_arg(x), .msg = NULL)

arg_and(x, ..., .arg = rlang::caller_arg(x), .msg = NULL)
```

## Arguments

- x:

  the argument to be checked

- ...:

  `arg_*()` functions or unevaluated function calls to be applied to
  `x`. See Examples.

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

For `arg_or()`, an error will be thrown only if `x` fails all of the
supplied checks. This can be useful when an argument can take on one of
several input types. For `arg_and()`, and error will be thrown if `x`
fails any of the supplied checks. This is less useful on its own, as the
checks can simply occur in sequence without `arg_and()`, but `arg_and()`
can be supplied to the `...` argument of `arg_or()` to create more
complicated criteria.

The `...` arguments can be passed either as functions, e.g.,

    arg_or(x,
           arg_number,
           arg_string,
           arg_flag)

or as unevaluated function calls with the `x` argument absent, e.g.,

    arg_or(x,
           arg_number(),
           arg_string(),
           arg_flag())

or as a mixture of both.

These functions do their best to provide a clean error message composed
of all the error messages for the failed checks. With many options, this
can yield a complicated error message, so use caution. `arg_and()` marks
with a check (`✔`) any passed checks and with an x (`✖`) any failed
checks.

## See also

[`arg_supplied()`](https://ngreifer.github.io/arg/reference/arg_supplied.md),
[`when_not_null()`](https://ngreifer.github.io/arg/reference/when_supplied.md)

## Examples

``` r
# `arg_or()`
f <- function(z) {
  arg_or(z,
         arg_number,
         arg_string,
         arg_flag)
}

try(f(1))      # No error
try(f("test")) # No error
try(f(TRUE))   # No error
#> Error in f(TRUE) : 
#>   `z` must be a number, a string, or a logical value (TRUE or FALSE).
try(f(1:4))    # Error: neither a number, string,
#> Error in f(1:4) : 
#>   `z` must be a single number, a string, or a logical value (TRUE or
#> FALSE).
#              #        or flag, but a vector

# `arg_and()`
g <- function(z) {
  arg_and(z,
          arg_counts,
          arg_length(len = 2),
          arg_lt(bound = 5))
}

try(g(c(1, 2)))     # No error
try(g(c(1, 7)))     # Error: not < 5
#> Error in g(c(1, 7)) : All of the following conditions must be met:
#> ✔ `z` must be a vector of counts (non-negative whole numeric values)
#> ✔ `z` must have length 2
#> ✖ each element of `z` must be less than 5
try(g(c(1.1, 2.1))) # Error: not counts
#> Error in g(c(1.1, 2.1)) : 
#>   All of the following conditions must be met:
#> ✖ `z` must be a vector of counts (non-negative whole numeric values)
#> ✔ `z` must have length 2
#> ✔ each element of `z` must be less than 5
try(g(4))           # Error: not length 2
#> Error in g(4) : All of the following conditions must be met:
#> ✔ `z` must be a vector of counts (non-negative whole numeric values)
#> ✖ `z` must have length 2
#> ✔ `z` must be less than 5
try(g("bad"))       # Error: no criteria satisfied
#> Error in g("bad") : All of the following conditions must be met:
#> ✖ `z` must be a vector of counts (non-negative whole numeric values)
#> ✖ `z` must have length 2
#> ✖ `z` must be less than 5

# Chaining together `arg_and()` and `arg_or()`
h <- function(z) {
  arg_or(z,
         arg_all_NA,
         arg_and(arg_count,
                 arg_lt(5)),
         arg_and(arg_string,
                 arg_element(c("a", "b", "c"))))
}

try(h(NA))  # No error
try(h(1))   # No error
try(h("a")) # No error
try(h(7))   # Error: not < 5
#> Error in h(7) : 
#>   At least one of the following conditions must be met:
#> • `z` must be NA
#> • `z` must be a count (a non-negative whole number) and less than 5
#> • `z` must be a string and one of "a", "b", or "c"
try(h("d")) # Error: not in "a", "b", or "c"
#> Error in h("d") : 
#>   At least one of the following conditions must be met:
#> • `z` must be NA
#> • `z` must be a count (a non-negative whole number) and less than 5
#> • `z` must be a string and one of "a", "b", or "c"
```
