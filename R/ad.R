#' Create a service principal (sp) and configure its access to Azure resources
#'
#' Prints a secret to the console as a JSON object.
#' Copy and set as a secret on your GitHub repository for use with the [Azure Login Action](https://github.com/Azure/login).
#'
#' @details
#' This is only necessary if you want an sp to programmatically access Azure resources on your behalf, as for example in a CI context.
#' If you only want interactive access to Azure resources, use [az_login()] instead.
#' You can manage existing sps on portal.azure.com.
#'
#' @section Warning:
#' The printed secret allows programmatic access to an Azure resource and can be used for malicious purposes.
#' **Ensure that the printed secret is never disclosed**.
#' For example, make sure that your console logs aren't disclosed.
#' For security reasons, this function will only run in an interactive session.
#'
#' @param name
#' A URI to use as the logic name.
#' It doesn't need to exist.
#' If not present (`NULL`), CLI will generate one (**not recommended**).
#'
#' This is not the app name *to which* you're giving access, but the "app" which will be doing the accessing (say, a CI service).
#' The purpose of this name is to document the purpose of the sp.
#' Default uses the GitHub Actions URL for the repo to indicate that the sp is used inside GitHub Actions.
#'
#' @param role
#' Role of the service principal.
#' Default value (or if `NULL`): `Contributor`.
#'
#' @param scopes
#' Space-separated list of scopes the service principal's role assignment applies to.
#' If `NULL` (**not recommended**) sets the root of the current subscription.
#' Should be as minimal as possible.
#' Defaults to [scope_down()].
#'
#' @param years
#' Number of years for which the credentials will be valid.
#' Default: 1 year.
#' Secrets should be rotated more often for extra security.
#'
#' @inheritDotParams az_cli_run
#'
#' @export
az_ad_sp_create_for_rbac <- function(name = get_ghactions_url(),
                                     role = "Contributor",
                                     scopes = scope_down(),
                                     years = 1,
                                     ...) {
  stopifnot(interactive())
  checkmate::assert_string(name, null.ok = TRUE)
  checkmate::assert_string(role, null.ok = TRUE)
  checkmate::assert_string(scopes, null.ok = TRUE)
  checkmate::assert_integerish(years, null.ok = TRUE)
  az_cli_run(
    cmd = c("ad", "sp", "create-for-rbac"),
    opt = c(
      if (!is.null(name)) c("--name", name),
      if (!is.null(role)) c("--role", role),
      if (!is.null(scopes)) c("--scopes", scopes),
      if (!is.null(years)) c("--years", years),
      "--sdk-auth"
    ),
    echo = TRUE,
    ...
  )
  cli::cli_alert_warning(c(
    "The above output contains secrets. ",
    "Ensure that it is nowever logged or otherwise disclosed."
  ))
  # for security, return NULL so that results aren't inadvertantly saved
  invisible(NULL)
}

#' @describeIn az_ad_sp_create_for_rbac Minimal scopes for a webapp, as recommended by [Azure Login GitHub Action](https://github.com/Azure/login), as of commit [`7e173d1`](https://github.com/Azure/login/commit/7e173d1a149e25731edf6857f7e506328c7c1d05).
#' Check back with the source for current security recommendations.
#' `subscription` requires an ID, does not work with a name.
#' Use `az_account_show()` to substitute an ID for a name as in the default.
#'
#' @inheritParams az_account
#'
#' @inheritParams az_configure
#'
#' @param provider Specific Azure resource and its name to scope down to (such as a webapp).
#' Defaults to a web app named via [az_configure()].
#' Set to `NULL` to skip (not recommended).
scope_down <- function(subscription = az_account_show()$id,
                       resource_group = az_configure_list()$resource_group,
                       provider = paste(
                         "Microsoft.Web", "sites", az_configure_list()$name,
                         sep = "/"
                       )) {
  checkmate::assert_string(subscription)
  checkmate::assert_string(resource_group)
  checkmate::assert_string(provider, null.ok = TRUE)
  res <- paste(
    "/subscriptions", subscription,
    "resourceGroups", resource_group,
    sep = "/"
  )
  if (is.null(provider)) return(res)
  paste(res, "providers", provider, sep = "/")
}
