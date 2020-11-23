#' Run Azure CLI
#' Wraps the [Azure Command-Line Interface (CLI)](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest).
#' @param cmd,req,opt,add
#' Command, required, optional, additional, extra parameters, as for [processx::run()]
#' `add` parameters are reserved for the user to pass down additional arguments to the Azure CLI.
#' `extra` parameters are reserved for internal use.
#' @inheritParams processx::run
#' @return (invisible) `stdout` parsed through [jsonlite::fromJSON()]
#' @export
az_cli_run <- function(cmd,
                       req = NULL,
                       opt = NULL,
                       add = NULL,
                       extra = NULL,
                       echo_cmd = FALSE,
                       echo = FALSE,
                       ...) {
  res <- processx::run(
    command = "az",
    # redudantly setting json output to be safe; this is expected below
    args = c(cmd, req, opt, "--output", "json", add, extra),
    echo_cmd = echo_cmd,
    spinner = TRUE,
    echo = echo
  )
  if (res$stdout == "") {
    # some az commands return nothing, so we have to protect against that
    return(invisible(NULL))
  }
  invisible(jsonlite::fromJSON(res$stdout))
}

#' @describeIn az_cli_run Run Azure CLI command with slot parameter (mostly `webapp` commands)
#' @keywords internal
#' @inheritParams az_webapp_deployment_slot_create
#' @export
az_cli_run_slot <- function(slot, ...) {
  az_cli_run(extra = c(if (!is.null(slot)) c("--slot", slot)), ...)
}
