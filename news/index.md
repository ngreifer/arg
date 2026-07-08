# Changelog

## *arg* (development version)

- Added
  [`arg_color()`](https://ngreifer.github.io/arg/reference/arg_color.md)
  (and variants) to check whether an argument corresponds to a valid
  color specification.

- Added
  [`arg_name()`](https://ngreifer.github.io/arg/reference/arg_index.md)
  and
  [`arg_names()`](https://ngreifer.github.io/arg/reference/arg_index.md)
  to check whether an argument is a vector of valid names of elements of
  an object.

- [`arg_index()`](https://ngreifer.github.io/arg/reference/arg_index.md)
  and
  [`arg_indices()`](https://ngreifer.github.io/arg/reference/arg_index.md)
  now check names for arbitrary objects, not just matrices and data
  frames.

- [`arg_counts()`](https://ngreifer.github.io/arg/reference/arg_numeric.md)
  and
  [`arg_whole_numeric()`](https://ngreifer.github.io/arg/reference/arg_numeric.md)
  (and their scalar equivalents) now check whether a value is a whole
  number using
  [`rlang::is_integerish()`](https://rlang.r-lib.org/reference/is_integerish.html)
  instead of the criterion used by
  [`all.equal()`](https://rdrr.io/r/base/all.equal.html).

- Fixed a bug where the message provided to `.msg` (if any) was not
  evaluated in the correct environment.

- Fixed several typos in the documentation and in some error messages.

- Added a testing suite.

## *arg* 0.1.1

CRAN release: 2026-05-27

- [`err()`](https://ngreifer.github.io/arg/reference/err.md),
  [`wrn()`](https://ngreifer.github.io/arg/reference/err.md), and
  [`msg()`](https://ngreifer.github.io/arg/reference/err.md) now pass
  arguments specified in `...` to
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html),
  [`rlang::warn()`](https://rlang.r-lib.org/reference/abort.html), and
  [`rlang::inform()`](https://rlang.r-lib.org/reference/abort.html),
  respectively.

- When an error is caused by a failure to process a given fixed argument
  (e.g., `bounds` in
  [`arg_gt()`](https://ngreifer.github.io/arg/reference/arg_between.md)
  or `len` in
  [`arg_length()`](https://ngreifer.github.io/arg/reference/arg_length.md)),
  that error is now thrown correctly in
  [`arg_or()`](https://ngreifer.github.io/arg/reference/arg_or.md),
  [`arg_and()`](https://ngreifer.github.io/arg/reference/arg_or.md),
  [`when_supplied()`](https://ngreifer.github.io/arg/reference/when_supplied.md),
  and
  [`when_not_null()`](https://ngreifer.github.io/arg/reference/when_supplied.md).
  Previously, it was bundled with the errors thrown to the ultimate user
  of the function `and_or()`, etc., was used in, which it made it
  confusing to diagnose.

- Fixed bugs with
  [`arg_or()`](https://ngreifer.github.io/arg/reference/arg_or.md),
  [`arg_and()`](https://ngreifer.github.io/arg/reference/arg_or.md),
  [`when_supplied()`](https://ngreifer.github.io/arg/reference/when_supplied.md),
  and
  [`when_not_null()`](https://ngreifer.github.io/arg/reference/when_supplied.md).

- Fixed a bug where an extra period might be added after an error
  message.

- When the empty string (`""`) is supplied to
  [`err()`](https://ngreifer.github.io/arg/reference/err.md), etc., it
  is no longer appended with a period.

- Improved error messages for
  [`arg_element()`](https://ngreifer.github.io/arg/reference/arg_element.md)
  and
  [`arg_not_element()`](https://ngreifer.github.io/arg/reference/arg_element.md).

- The `.msg` argument of `arg_*()` functions is now checked to ensure it
  is a string when not `NULL`.

## *arg* 0.1.0

CRAN release: 2026-04-09

- Initial CRAN submission.
