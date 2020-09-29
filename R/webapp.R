#' Manage web apps
#'
#' @param restart whether to restart the web app.
#'
#' @inheritParams az_account_set
#' @inheritDotParams az_cli_run
#'
#' @export
az_webapp <- function(slot = NULL, restart = TRUE,
                      ...) {
  checkmate::assert_flag(restart)
  az_webapp_create(...)
  if (!is.null(slot)) az_webapp_deployment_slot_create(slot = slot, ...)
  az_webapp_config_container_set(slot = slot, ...)
  az_webapp_update(slot = slot, ...)
  az_webapp_config_set(slot = slot, ...)
  az_webapp_config_appsettings_set(slot = slot, ...)
  if (restart) az_webapp_restart(slot = slot, ...)
}

#' @describeIn az_webapp Create a web app
#'
#' @inheritParams az_configure
#'
#' @param plan
#' Name or resource id of the app service plan.
#'
#' @param startup_file
#' `docker run` [`[COMMAND]`](https://docs.docker.com/engine/reference/run/) to use inside of your custom image `deployment_container_image_name`.
#' Defaults to `NULL`, in which case the container is expected to start up shiny automatically (recommended).
#' For details on the shiny startup command, see the examples.
#'
#' **The `[EXPR]` (anything after `-e`) must not be quoted, and must not contain spaces ([#27](https://github.com/subugoe/shinycaas/issues/27))**.
#' For example, the following `startup-file`s are valid (if nonsensical, because they don't start a shiny app)
#' - `"Rscript -e 1+1"` (no spaces)
#' - `"Rscript -e print('foo')"` (no spaces, no quoting *of* the `[EXPR]`)
#'
#' The following `startup-file`s are *invalid*:
#' - `"Rscript -e 1 + 1"` (spaces inside `[EXPR]`)
#' - `"Rscript -e '1+1'"` (quoting of `[EXPR]` would be treated as `"Rscript -e '\"1+1\"'"`).
az_webapp_create <- function(name = NULL,
                             plan,
                             resource_group = NULL,
                             deployment_container_image_name,
                             startup_file = NULL,
                             subscription = NULL,
                             ...) {
  checkmate::assert_string(name, null.ok = TRUE)
  checkmate::assert_string(plan, null.ok = FALSE)
  checkmate::assert_string(resource_group, null.ok = TRUE)
  checkmate::assert_string(deployment_container_image_name, null.ok = FALSE)
  checkmate::assert_string(startup_file, null.ok = TRUE)
  cli::cli_alert_info("Creating or updating web app ...")
  az_cli_run(
    cmd = c("webapp", "create"),
    req = c(
      if (!is.null(name)) c("--name", name),
      "--plan", plan,
      if (!is.null(resource_group)) c("--resource-group", resource_group)
    ),
    opt = c(
      # az webapp create, though undocumented, requires either an image name or a runtime
      # other container settings are set below
      "--deployment-container-image-name", deployment_container_image_name,
      if (!is.null(startup_file)) c("--startup-file", startup_file),
      if (!is.null(subscription)) c("--subscription", subscription)
      # todo also pass on tags #25
    ),
    ...
  )
}

#' @describeIn az_webapp Delete a web app
az_webapp_delete <- function(name = NULL, slot = NULL, ...) {
  az_cli_run(
    cmd = c("webapp", "delete"),
    opt = c(
      if (!is.null(name)) c("--name", name),
      if (!is.null(slot)) c("--slot", slot)
    ),
    ...
  )
}

#' @describeIn az_webapp List web apps
az_webapp_list <- function(...) {
  az_cli_run(cmd = c("webapp", "list"), ...)
}

#' @describeIn az_webapp Gets the details of a web app
az_webapp_show <- function(slot = NULL, ...) {
  az_cli_run(
    cmd = c("webapp", "show"),
    opt = c(
      if (!is.null(slot)) c("--slot", slot)
    ),
    ...
  )
}

#' @describeIn az_webapp Create a deployment slot
#'
#' @param slot
#' The name of the [deployment slot](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots).
#' Defaults to the production slot if not specified.
#' Only available for higher app service plan tiers.
az_webapp_deployment_slot_create <- function(name = NULL,
                                             resource_group = NULL,
                                             slot,
                                             ...) {
  checkmate::assert_string(slot, null.ok = FALSE)
  cli::cli_alert_info("Creating deployment slot ...")
  az_cli_run(
    cmd = c("webapp", "deployment", "slot", "create"),
    req = c(
      if (!is.null(name)) c("--name", name),
      if (!is.null(resource_group)) c("--resource-group", resource_group),
      "--slot", slot
    ),
    ...
  )
}

#' @describeIn az_webapp Set a web app container's settings
#'
#' @param deployment_container_image_name
#' The custom image name and optionally the tag name.
#' Image must
#' - include everything needed to run the shiny app, including shiny itself,
#'   but *does not* need to include shiny server or other software to route, load balance and serve shiny,
#' - include an `ENTRYPOINT` and/or [`CMD`](https://docs.docker.com/engine/reference/builder/#cmd) instruction to start shiny automatically (recommended), *or* shiny must be started via the `startup_file` argument.
#'
#' @param docker_registry_server_url
#' The container registry server url.
#' Defaults to `NULL`, in which case the azure default, [docker hub](http://hub.docker.com) is used.
#'
#' @param docker_registry_server_user,docker_registry_server_password
#' Credentials for private container registries.
#' Defaults to `NULL` for public registries.
#' Do not expose your credentials in public code; it's best to use secret environment variables.
az_webapp_config_container_set <- function(deployment_container_image_name,
                                           docker_registry_server_url = NULL,
                                           docker_registry_server_user = NULL,
                                           docker_registry_server_password = NULL,
                                           slot = NULL,
                                           ...) {
  checkmate::assert_string(deployment_container_image_name)
  checkmate::assert_string(docker_registry_server_url, null.ok = TRUE)
  checkmate::assert_string(docker_registry_server_user, null.ok = TRUE)
  checkmate::assert_string(docker_registry_server_password, null.ok = TRUE)
  cli::cli_alert_info("Setting web app container settings ...")
  az_cli_run(
    cmd = c("webapp", "config", "container", "set"),
    opt = c(
      # redundant, container is already set above, but safer\
      # otherwise command might be called with no args
      "--docker-custom-image-name", deployment_container_image_name,
      if (!is.null(docker_registry_server_url)) {
        c("--docker-registry-server-url", docker_registry_server_url)
      },
      if (!is.null(docker_registry_server_user)) {
        c("--docker-registry-server-user", docker_registry_server_user)
      },
      if (!is.null(docker_registry_server_password)) {
        c("--docker-registry-server-password", docker_registry_server_password)
      },
      if (!is.null(slot)) c("--slot", slot)
    ),
    ...
  )
}

#' @describeIn az_webapp Update a web app
az_webapp_update <- function(slot = NULL, ...) {
  cli::cli_alert_info("Setting web app tags ...")
  # for some reason, this is not part of the webapp config, though it is on portal.azure.com
  az_cli_run(
    cmd = c("webapp", "update"),
    opt = c(
      "--client-affinity-enabled", "true", # send traffic to same machine
      "--https-only", "true",
      if (!is.null(slot)) {
        c("--slot", slot)
      }
    ),
    ...
  )
}

#' @describeIn az_webapp Set a web app's configuration
az_webapp_config_set <- function(slot = NULL, ...) {
  cli::cli_alert_info("Setting web app configuration ...")
  az_cli_run(
    cmd = c("webapp", "config", "set"),
    opt = c(
      "--always-on", "true",
      "--ftps-state", "disabled", # not needed
      "--web-sockets-enabled", "true", # needed to serve shiny
      "--http20-enabled", "true",
      "--min-tls-version", "1.2",
      if (!is.null(slot)) c("--slot", slot)
    ),
    ...
  )
}

#' @describeIn az_webapp Get details of a web app container's settings
az_webapp_config_container_show <- function(slot = NULL, ...) {
  az_cli_run(
    cmd = c("webapp", "config", "container", "show"),
    opt = c(if (!is.null(slot)) c("--slot", slot)),
    ...
  )
}

#' @describeIn az_webapp Set a web app's settings
az_webapp_config_appsettings_set <- function(slot = NULL, ...) {
  # weirdly this cannot be set in the above
  az_cli_run(
    cmd = c("webapp", "config", "appsettings", "set"),
    opt = c(
      "--settings", "DOCKER_ENABLE_CI=false",
      if (!is.null(slot)) c("--slot", slot)
    ),
    ...
  )
}

#' @describeIn az_webapp Restarts the web app
az_webapp_restart <- function(slot = NULL, ...) {
  cli::cli_alert_info("Restaring web app ...")
  az_cli_run(
    cmd = c("webapp", "restart"),
    opt = c(if (!is.null(slot)) c("--slot", slot)),
    ...
  )
}

#' @describeIn az_webapp Open a web app in a browser
az_webapp_browse <- function(slot = NULL, ...) {
  az_cli_run(
    cmd = c("webapp", "browse"),
    opt = c(if (!is.null(slot)) c("--slot", slot)),
    ...
  )
}
