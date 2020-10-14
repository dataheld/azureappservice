local_az_account <- function(env = parent.frame()) {
  # this will error out if cli has not been authorised
  old_default <- az_account_show()$name
  suppressMessages(az_account_set("subugoe"))
  withr::defer(suppressMessages(az_account_set(old_default)), env = env)
}

local_az_configure <- function(name = NULL,
                               env = parent.frame()) {
  if (is.null(name)) {
    name <- make_testappname("")
  }
  suppressMessages(az_configure(name = name, resource_group = "hoad"))
  withr::defer(fs::dir_delete(".azure"), env = env)
}

local_az_webapp_create <- function(deployment_container_image_name = "rocker/shiny:4.0.2",
                                   env = parent.frame(),
                                   ...) {
  suppressMessages(az_webapp_create(
    plan = "hoad",
    resource_group = "hoad",
    deployment_container_image_name = deployment_container_image_name,
    ...
  ))
  withr::defer(az_webapp_delete(), env = env)
}

# to be safe, app names should be disambiguated
get_random_string <- function(length = 6) {
  paste0(sample(LETTERS, size = length), collapse = "")
}
append_random_suffix <- function(x, length = 6) {
  paste(x, get_random_string(length = length), sep = "-")
}
make_testappname <- function(desc = "") {
  append_random_suffix(paste(
    "testthat",
    gsub(" ", "-", desc, fixed = TRUE),
    sep = "-")
  )
}
