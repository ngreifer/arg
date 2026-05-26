arg News and Updates
======

# *arg* 0.1.1

* `err()`, `wrn()`, and `msg()` now pass arguments specified in `...` to `rlang::abort()`, `rlang::warn()`, and `rlang::inform()`, respectively.

* When an error is caused by a failure to process a given fixed argument (e.g., `bounds` in `arg_gt()` or `len` in `arg_length()`), that error is now thrown correctly in `arg_or()`, `arg_and()`, `when_supplied()`, and `when_not_null()`. Previously, it was bundled with the errors thrown to the ultimate user of the function `and_or()`, etc., was used in, which it made it confusing to diagnose.

* Fixed bugs with `arg_or()`, `arg_and()`, `when_supplied()`, and `when_not_null()`.

* Fixed a bug where an extra period might be added after an error message.

* When the empty string (`""`) is supplied to `err()`, etc., it is no longer appended with a period.

* Improved error messages for `arg_element()` and `arg_not_element()`.

* The `.msg` argument of `arg_*()` functions is now checked to ensure it is a string when not `NULL`.

# *arg* 0.1.0

* Initial CRAN submission.
