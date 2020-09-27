#' Run Azure CLI
#' Wraps the [Azure Command-Line Interface (CLI)](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest).
#' @param cmd,req,opt,add
#' Command, required, optional, additional parameters, as for [processx::run()]
#' `add` parameters are reserved for the user to pass down additional arguments.
#' @inheritParams processx::run
#' @return (invisible) `stdout` parsed through [jsonlite::fromJSON()]
#' @export
az_cli_run <- function(cmd,
                       req = NULL,
                       opt = NULL,
                       add = NULL,
                       echo_cmd = FALSE,
                       echo = FALSE,
                       ...) {
  res <- processx::run(
    command = "az",
    # redudantly setting json output to be safe; this is expected below
    args = c(cmd, req, opt, "--output", "json", add),
    echo_cmd = echo_cmd,
    spinner = TRUE,
    echo = echo
  )
  if (res$stdout == "") {
    # some az commands return nothing, so we have to protect against that
    return(NULL)
  }
  invisible(jsonlite::fromJSON(res$stdout))
}
