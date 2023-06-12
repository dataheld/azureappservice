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
  shiny::runApp(app(), host = host, port = port_shiny)
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

#' Test app
#' @noRd
app <- function() {
  shiny::shinyApp(
    ui = bslib::page(nav_menu_source()),
    server = function(input, output, session) TRUE
  )
}

#' Build info
#' Useful to print inside shiny app.
#'
#' @details
#' This should be evaluated only when the app is built.
#' @noRd
show_build_info <- function() {
  version <- utils::packageVersion("azureappservice")
  # appease linter, check
  version
  is_in_docker <- Sys.getenv("GITHUB_REF_NAME") != ""
  version <- glue::glue("version {version}")
  scm <- {
    if (is_in_docker) {
      glue::glue_collapse(
        c(
          glue::glue("from git sha {Sys.getenv('GITHUB_SHA')},"),
          glue::glue("on git branch {Sys.getenv('GITHUB_REF_NAME')}")
        )
      )
    } else {
      glue::glue("local")
    }
  }
  build_time <- lubridate::format_ISO8601(
    build_time,
    usetz = TRUE,
    precision = "ymdhm"
  )
  launched <- lubridate::format_ISO8601(
    run_time(),
    usetz = TRUE,
    precision = "ymdhm"
  )
  built <- glue::glue("built at {build_time}")
  launched <- glue::glue("launched at {launched}")
  c(version = version, scm = scm, built = built, launched = launched)
}

#' Store build time in package
#' @noRd
build_time <- lubridate::now(tz = "Europe/Berlin")

#' Get run time
#' @noRd
run_time <- function() lubridate::now(tz = "Europe/Berlin")

#' Source info
#' @noRd
nav_menu_source <- function() {
  all <- show_build_info()
  bslib::nav_menu(
    title = "Source",
    bslib::nav_item(
      shiny::tags$a(
        shiny::tags$i(bsicons::bs_icon("github")),
        "Repository",
        href = "https://github.com/dataheld/azureappservice"
      )
    ),
    bslib::nav_item(
      shiny::tags$a(
        shiny::tags$i(bsicons::bs_icon("git")), all["scm"]
      )
    ),
    bslib::nav_item(
      shiny::tags$a(
        shiny::tags$i(bsicons::bs_icon("box")), all["built"]
      )
    ),
    bslib::nav_item(
      shiny::tags$a(
        shiny::tags$i(bsicons::bs_icon("play")), all["launched"]
      )
    ),
    icon = shiny::tags$i(bsicons::bs_icon("code")),
    align = "right"
  )
}

#' Link to gh repo
#' @noRd
link_gh <- shiny::tags$a(
  shiny::tags$i(bsicons::bs_icon("github")),
  "Repository",
  href = "https://github.com/dataheld/azureappservice"
)
