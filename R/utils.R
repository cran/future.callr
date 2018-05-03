is_na <- function(x) {
  if (length(x) != 1L) return(FALSE)
  is.na(x)
}

is_false <- function(x) {
  if (length(x) != 1L) return(FALSE)
  x <- as.logical(x)
  x <- unclass(x)
  identical(FALSE, x)
}

stop_if_not <- function(...) {
  res <- list(...)
  for (ii in 1L:length(res)) {
    res_ii <- .subset2(res, ii)
    if (length(res_ii) != 1L || is.na(res_ii) || !res_ii) {
        mc <- match.call()
        call <- deparse(mc[[ii + 1]], width.cutoff = 60L)
        if (length(call) > 1L) call <- paste(call[1L], "....")
        stop(sprintf("%s is not TRUE", sQuote(call)),
             call. = FALSE, domain = NA)
    }
  }
  
  NULL
}

## Adopted R.utils 2.1.0 (2015-06-15)
#' @importFrom utils capture.output
capture_output <- function(expr, envir = parent.frame(), ...) {
  res <- eval({
    file <- rawConnection(raw(0L), open = "w")
    on.exit(close(file))
    capture.output(expr, file = file)
    rawToChar(rawConnectionValue(file))
  }, envir = envir, enclos = baseenv())
  unlist(strsplit(res, split = "\n", fixed = TRUE), use.names = FALSE)
}

printf <- function(...) cat(sprintf(...))

mcat <- function(...) message(..., appendLF = FALSE)

mprintf <- function(...) message(sprintf(...), appendLF = FALSE)

mprint <- function(...) {
  bfr <- capture_output(print(...))
  bfr <- paste(c(bfr, ""), collapse = "\n")
  message(bfr, appendLF = FALSE)
}

#' @importFrom utils str
mstr <- function(...) {
  bfr <- capture_output(str(...))
  bfr <- paste(c(bfr, ""), collapse = "\n")
  message(bfr, appendLF = FALSE)
}

## From R.utils 2.0.2 (2015-05-23)
hpaste <- function(..., sep="", collapse=", ", last_collapse=NULL,
                   max_head=if (missing(last_collapse)) 3 else Inf,
                   max_tail=if (is.finite(max_head)) 1 else Inf,
                   abbreviate="...") {
  max_head <- as.double(max_head)
  max_tail <- as.double(max_tail)
  if (is.null(last_collapse)) last_collapse <- collapse

  # Build vector 'x'
  x <- paste(..., sep = sep)
  n <- length(x)

  # Nothing todo?
  if (n == 0) return(x)
  if (is.null(collapse)) return(x)

  # Abbreviate?
  if (n > max_head + max_tail + 1) {
    head <- x[seq_len(max_head)]
    tail <- rev(rev(x)[seq_len(max_tail)])
    x <- c(head, abbreviate, tail)
    n <- length(x)
  }

  if (!is.null(collapse) && n > 1) {
    if (last_collapse == collapse) {
      x <- paste(x, collapse = collapse)
    } else {
      x_head <- paste(x[1:(n - 1)], collapse = collapse)
      x <- paste(x_head, x[n], sep = last_collapse)
    }
  }

  x
}

## Adopted from R.oo 1.19.0 (2015-06-15)
trim <- function(x, ...) {
  sub("[\t\n\f\r ]*$", "", sub("^[\t\n\f\r ]*", "", x))
}

hexpr <- function(expr, trim = TRUE, collapse = "; ", maxHead = 6L, maxTail = 3L, 
...) {
  code <- deparse(expr)
  if (trim) code <- trim(code)
  hpaste(code, collapse = collapse, maxHead = maxHead, maxTail = maxTail, ...)
}

import_from <- function(name, default = NULL, package) {
  ns <- getNamespace(package)
  if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
    get(name, mode = "function", envir = ns, inherits = FALSE)
  } else if (!is.null(default)) {
    default
  } else {
    stop(sprintf("No such '%s' function: %s()", package, name))
  }
}

import_future <- function(name, default = NULL) {
  import_from(name, default = default, package = "future")
}

## Tests if the current OS is of a certain type
is_os <- function(name) {
  if (name == "windows") {
    return(.Platform$OS.type == "windows")
  } else {
    grepl(paste0("^", name), R.version$os)
  }
}