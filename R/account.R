#' Manage Azure subscription information
#'
#' Subscription defaults to `NULL`, in which case the subscription is expected to be enabled in the azure CLI cache already.
#' Appends and sets to default `subscription`, if provided.
#' Errors out if no subscription is enabled.
#'
#' @inheritDotParams az_cli_run
#'
#' @export
az_account <- function(subscription = NULL, ...) {
  if (!is.null(subscription)) {
    az_account_set(subscription = subscription, ...)
  }
  res <- az_account_list(...)
  if (length(res) == 0) {
    stop("There are no enabled subscriptions.")
  }
  cli::cli_alert_info(
    "Found enabled subscription{?s} named {.field {res$name}}."
  )
  invisible(res)
}

#' @describeIn az_account Get a list of subscriptions for the logged in account.
#' @export
az_account_list <- function(...) {
  az_cli_run(cmd = c("account", "list"), ...)
}

#' @describeIn az_account Get the details of a subscription.
#' If the subscription isn't specified, shows the details of the default subscription.
#' @export
az_account_show <- function(subscription = NULL, ...) {
  az_cli_run(
    cmd = c("account", "show"),
    opt = c(
      if (!is.null(subscription)) c("--subscription", subscription)
    ),
    ...
  )
}

#' @describeIn az_account Set a subscription to be the current active subscription.
#'
#' @details
#' Subscriptions are kept in the local azure CLI cache, so you should not have to run this more than once.
#' On GitHub Actions, [the azure login action](https://github.com/azure/login) will already set up a subscription.
#'
#' @param subscription
#' Name or ID of the Azure subscription to which costs are billed.
#' According to an upvoted answer on Stack Overflow, [Azure subscription IDs need not be considered a secret or personal identifiable information (PII)](https://stackoverflow.com/questions/45661109/are-azure-subscription-id-aad-tenant-id-and-aad-app-client-id-considered-secre).
#' However, depending your applicable context and policies, you may want to provide this argument as a secret.
#'
#' To find out which subscriptions you are currently authorised to use, run `print(az_account_list())`.
#' @export
az_account_set <- function(subscription, ...) {
  checkmate::assert_string(subscription)
  cli::cli_alert_info("Setting subscription ...")
  az_cli_run(
    cmd = c("account", "set"),
    req = c("--subscription", subscription),
    ...
  )
}
