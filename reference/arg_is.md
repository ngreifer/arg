# Check Argument Class

Checks whether an argument is a of a specified class (`arg_is()`) or is
not of a specified class (`arg_is_not()`).

## Usage

``` r
arg_is(x, class, .arg = rlang::caller_arg(x), .msg = NULL, .call)

arg_is_not(x, class, .arg = rlang::caller_arg(x), .msg = NULL, .call)
```

## Arguments

- x:

  the argument to be checked

- class:

  a character vector of one or more classes to check `x` against.

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

`arg_is()` and `arg_is_not()` use
[`inherits()`](https://rdrr.io/r/base/class.html) to test for class
membership. `arg_is()` throws an error only if no elements of `class(x)`
are in `class`. `arg_is_not()` throws an error if any elements of
`class(x)` are in `class`.

Sometimes this can be too permissive; combining `arg_is()` with
[`arg_and()`](https://ngreifer.github.io/arg/reference/arg_or.md) can be
useful for requiring that an object is of multiple classes.
Alternatively, combining `arg_is_not()` with
[`arg_or()`](https://ngreifer.github.io/arg/reference/arg_or.md) can be
useful for requiring that an object is not a specific combination of
classes. See Examples.

## See also

[`inherits()`](https://rdrr.io/r/base/class.html),
[`arg_or()`](https://ngreifer.github.io/arg/reference/arg_or.md);
[`arg_data()`](https://ngreifer.github.io/arg/reference/arg_data.md) for
testing for specific kinds of objects (vectors, matrices, data frames,
and lists)

## Examples

``` r
obj <- structure(list(1),
                 class = "test")

try(arg_is(obj, "test"))            # No error
try(arg_is(obj, c("test", "quiz"))) # No error
try(arg_is(obj, "quiz"))            # Error
#> Error : `obj` must inherit from class <quiz>.

try(arg_is_not(obj, "test"))            # Error
#> Error : `obj` must not inherit from class <test>.
try(arg_is_not(obj, c("test", "quiz"))) # Error
#> Error : `obj` must not inherit from class <test/quiz>.
try(arg_is_not(obj, "quiz"))            # No error

# Multiple classes
obj2 <- structure(list(1),
                  class = c("test", "essay"))

try(arg_is(obj2, c("test", "quiz")))     # No error
try(arg_is_not(obj2, c("test", "quiz"))) # Error
#> Error : `obj2` must not inherit from class <test/quiz>.

## Require argument to be of multiple classes
try(arg_and(obj2,
            arg_is("test"),
            arg_is("quiz")))
#> Error : `n` must be a whole number, not a call.

## Require argument to not be a specific combination of
## multiple classes
try(arg_or(obj2,
           arg_is_not("test"),
           arg_is_not("essay")))
#> Error in rlang::caller_fn(arg_call) : 
#>   `n` must be a whole number, not a call.
```
