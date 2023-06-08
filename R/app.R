#' Serving Shiny App
#' Mostly used as an `ENTRYPOINT` inside the Docker image.
#'
#' @section Warning:
#' This may expose sensitive information on `0.0.0.0` -- use with caution.
#'
#' @export
serve_all <- function() {
  host <- Sys.getenv("R_HOST", "127.0.0.1")
  port_shiny <- get_port_safely(3838L, host = host)
  shiny::runExample("01_hello", host = host, port = port_shiny)
}

#' Helper to get a safe port
#' @noRd
get_port_safely <- function(preferred, host) {
  checkmate::assert_scalar(preferred)
  checkmate::assert_subset(host, choices = c("0.0.0.0", "127.0.0.1"))
  actual <- servr::random_port(preferred, host = host)
  msg <- "Preferred port was not available."
  if (preferred != actual) {
    if (host == "0.0.0.0") {
      rlang::abort(message = msg)
    } else {
      rlang::warn(message = paste(msg, "Using random port."))
    }
  }
  invisible(actual)
}

test_fun <- function() AzureRMR::is_url()
