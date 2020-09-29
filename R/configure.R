#' Manage Azure CLI configuration
#'
#' Overwrites defaults for the Azure CLI to `.azure/` directory (**side effect**), if arguments are provided.
#' Errors out if a default is missing.
#'
# TODO remove this warning https://github.com/subugoe/AzureAppService/issues/19
#' @details
#' Because of a [bug](https://github.com/Azure/azure-cli/issues/15014), the Azure CLI will always include defaults at `~/.azure/`.
#' These hidden defaults can interfere with these functions.
#' Make sure that you have no default `name` and `resource_group` in the global azure default config in your `HOME` directory.
#'
#' @param name
#' Name of the web app.
#' (In the Azure CLI, this argument is sometimes known as `name`, and sometimes as `web`).
#'
#' @param resource_group
#' The [Azure resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal) to which the app service should belong.
#'
#' @inheritDotParams az_cli_run
#'
#' @export
az_configure <- function(name = NULL, resource_group = NULL, ...) {
  is_changed <- FALSE
  if (!is.null(name)) {
    az_cli_run(
      cmd = "configure",
      opt = c(
        # only applies to current folder, useful if there are various projects
        "--scope", "local",
        "--defaults", paste0("web=", name)
      ),
      ...
    )
    is_changed <- TRUE
  }
  if (!is.null(resource_group)) {
    az_cli_run(
      cmd = "configure",
      opt = c(
        # only applies to current folder, useful if there are various projects
        "--scope", "local",
        "--defaults", paste0("group=", resource_group)
      ),
      ...
    )
    is_changed <- TRUE
  }
  if (is_changed) {
    cli::cli_alert_info(
      "Wrote defaults to {.file .azure/} at the working directory."
    )
  }
  res <- az_configure_list(...)
  if (is.null(res$resource_group)) {
    stop("No resource group provided.")
  }
  # not quite strict/consistent, but it makes life easier if no name is allowed
  cli::cli_alert_success(
    "Using resource group {.field {res$resource_group}} and name {.field {res$name}} ..."
  )
  invisible(res)
}

#' @describeIn az_configure List defaults
az_configure_list <- function(...) {
  output <- list(
    resource_group = NULL,
    name = NULL
  )
  res <- az_cli_run(
    cmd = "configure",
    opt = c(
      "--list-defaults", "true",
      # only applies to current folder, useful if there are various projects
      "--scope", "local"
    ),
    ...
  )
  if (length(res) == 0) {
    return(output)
  }
  if (checkmate::test_string(res[res$name == "group", "value"], min.chars = 1)) {
    output$resource_group <- res[res$name == "group", "value"]
  }
  if (checkmate::test_string(res[res$name == "web", "value"], min.chars = 1)) {
    output$name <- res[res$name == "web", "value"]
  }
  output
}
