is_null <- function(x) {length(x) == 0L}
is_not_null <- function(x) {!is_null(x)}

check_if_zero <- function(x, tolerance = sqrt(.Machine$double.eps)) {
  # this is the default tolerance used in all.equal
  abs(x) < tolerance
}

is_error <- function(x) {
  tryCatch(capture.output({out <- x}, type = "message"),
                 error = function(e) {
                   return(TRUE)
                 }) |>
    suppressWarnings() |>
    suppressMessages() |>
    invisible()

    inherits(out, c("error", "try-error"))
}

safe_any <- function(x) {
  x <- suppressWarnings(x)
  x[is.na(x)] <- FALSE
  any(x)
}
safe_all <- function(x) {
  x <- suppressWarnings(x)
  x[is.na(x)] <- FALSE
  all(x)
}

ansi_trim <- function(x, left = 0, right = 0) {
  n <- cli::ansi_nchar(x)

  cli::ansi_substr(x, left + 1L, n - right)
}
ansi_upper_first <- function(x) {
  starts_with_letters <- cli::ansi_grepl("^[[:alpha:]]", x)

  if (any(starts_with_letters)) {
    for (i in which(starts_with_letters)) {
      if (cli::ansi_nchar(x[i]) > 1L) {
        x[i] <- paste0(cli::ansi_toupper(cli::ansi_substr(x[i], 1L, 1L)),
                      cli::ansi_substr(x[i], 2L, cli::ansi_nchar(x[i])))

      }
      else {
        x[i] <- cli::ansi_toupper(x[i])
      }
    }
  }

  x
}
ansi_lower_first <- function(x) {
  starts_with_letters <- cli::ansi_grepl("^[[:alpha:]]", x)

  if (any(starts_with_letters)) {
    for (i in which(starts_with_letters)) {
      if (cli::ansi_nchar(x[i]) > 1L) {
        x[i] <- paste0(cli::ansi_tolower(cli::ansi_substr(x[i], 1L, 1L)),
                       cli::ansi_substr(x[i], 2L, cli::ansi_nchar(x[i])))

      }
      else {
        x[i] <- cli::ansi_tolower(x[i])
      }
    }
  }

  x
}

trim_final_punct <- function(x) {
  ends_with_punct <- cli::ansi_grepl("([.]|[?]|[!])$", x)

  if (any(ends_with_punct)) {
    x[ends_with_punct] <- ansi_trim(x[ends_with_punct], right = 1L)
  }

  x
}

`%or%` <- function(x, y) {
  if (is_null(x)) y else x
}
