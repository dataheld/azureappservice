#' Log in to Azure
#'
#' Helper for **interactive** login.
#'
#' @inheritDotParams az_cli_run
#'
#' @export
az_login <- function(...) {
  az_cli_run(
    cmd = "login",
    ...
  )
}
