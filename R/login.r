#' Log in to Azure
#'
#' Helper for **interactive** login.
#'
#' @inheritDotParams az_cli_run
#'
#' @export
az_login <- function(...) {
  stopifnot(interactive())
  az_cli_run(
    cmd = "login",
    ...
  )
}
