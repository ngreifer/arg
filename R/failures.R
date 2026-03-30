make_fail <- function(a0, x) {
  fn <- rlang::call_name(a0)

  a <- match.call(match.fun(fn), a0, expand.dots = FALSE)

  args <- rlang::call_args(a)
  for (i in which(names(args) != "x")) {
    args[[i]] <- eval.parent(args[[i]])
  }

  if (fn %in% c("arg_and", "arg_or")) {
    new_args <- lapply(args[["..."]], function(j) {
      j <- .to_arg_fun_call(j)

      if ("x" %in% names(j)) {
        j <- rlang::call_modify(j, !!!list(x = args[["x"]]))
      }
      if (".arg" %in% names(j)) {
        j <- rlang::call_modify(j, !!!list(.arg = args[[".arg"]]))
      }
      if (".call" %in% names(j)) {
        j <- rlang::call_modify(j, !!!list(.call = NULL))
      }

      make_fail(j, x)
    })

    a[names(a) == "..."] <- NULL

    a <- rlang::call_modify(a, !!!new_args)

    return(a)
  }

  new_args <-  switch(
    fn,
    arg_between = {
      list(x = rep(NaN, length(x)))
    },
    arg_dots_not_supplied = {
      list("..." = list(1L))
    },
    arg_dots_supplied = {
      list("..." = rlang::zap())
    },
    arg_element = {
      if (anyNA(args[["values"]])) {
        b <- 1
        while (is.element(b, args[["values"]])) b <- b + 1
        list(x = rep.int(b, length(x)))
      }
      else {
        list(x = rep.int(NA, length(x)))
      }
    },
    arg_equal = {
      if (isTRUE(all.equal(x, NaN))) list(x = 1L)
      else list(x = NaN)
    },
    arg_gt = {
      list(x = rep(NaN, length(x)))
    },
    arg_gte = {
      list(x = rep(NaN, length(x)))
    },
    arg_index = {
      list(x = rep.int(NaN, 2L))
    },
    arg_indices = {
      list(x = rep.int(NaN, length(x)))
    },
    arg_is = {
      list(x = structure(list(), class = paste(args[["class"]], collapse = "")))
    },
    arg_is_not = {
      list(x = structure(list(), class = args[["class"]]))
    },
    arg_length = {
      list(x = rep.int(x, max(args[["len"]] + 1L)))
    },
    arg_list = {
      list(x = 1L)
    },
    arg_lt = {
      list(x = rep(NaN, length(x)))
    },
    arg_lte = {
      list(x = rep(NaN, length(x)))
    },
    arg_no_NA = {
      list(x = rep.int(NA, length(x)))
    },
    arg_non_null = {
      list(x = NULL)
    },
    arg_not_element = {
      list(x = rep.int(args[["values"]][1L], length(x)))
    },
    arg_not_equal = {
      list(x = args[["x2"]])
    },
    # arg_or,
    arg_supplied = {
      list(x = rlang::missing_arg())
    },
    {
      list(x = .evil_object)
    })

  rlang::call_modify(a, !!!new_args)
}

.evil_object <- list("5d1561a3444c04149260df7165afc077db2ab5a7",
                     844337346787.926008639,
                     NA, 1, 1) |>
  setNames(c("e7bf8d80193c2fd16935c965c174db395b9824e4", NA, "hehe", "a", "b")) |>
  structure(class = "arg_evil_object")
