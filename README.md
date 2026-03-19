
<!-- README.md is generated from README.Rmd. Please edit that file -->

# arg: Clean, Simple Argument Checking

<!-- badges: start -->

<!-- badges: end -->

*arg* produces nice, clean error messages for checking function
arguments in R packages. I developed *arg* because I often found myself
writing the same error messages in my packages, and I wasn’t satisfied
with the other similar R packages available. *arg* uses *cli* to produce
clean and clear errors without requiring much programming from the
developer. These messages are designed to be clear to the user, not
using complicated language. Many messages adapt to the type of
(incorrect) input received.

``` r
library(arg)

z <- "a string"

arg_string(z)

arg_number(z)
#> Error:
#> ! `z` must be a number.

arg_and(z,
        arg_string,
        arg_length(2L))
#> Error:
#> ! All of the following conditions must be met:
#> ✔ `z` must be a string
#> ✖ `z` must have length 2

arg_or(z,
       arg_is_NA,
       arg_flag,
       arg_count)
#> Error:
#> ! `z` must be NA, a logical value (TRUE or FALSE), or a count (a
#>   non-negative whole number).
```

The name “arg” is meant to be short for “argument”, but also perhaps
represents the sound you would make if you were to encounter an error
when running some code. Hopefully *arg* reduces the number of times
users say “arg”.

If you use any of my R packages, including *MatchIt*, *WeightIt*,
*cobalt*, *optweight*, or *adrftools*, you may already be using *arg*!

## Installation

You can install the development version of arg from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ngreifer/arg")
```

You can install the stable version on CRAN using

``` r
install.packages("arg")
#> Error in `contrib.url()`:
#> ! trying to use CRAN without setting a mirror
```

## Related packages

*arg* has a similar function to other existing packages. These packages
may be better for your purposes, and *arg* is not meant to compete with
them.

- *checkmate*
- *checkarg*
- *erify*
- *favr*
- *assertions*
- *dreamerr*
