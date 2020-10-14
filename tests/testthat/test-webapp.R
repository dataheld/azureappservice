test_that(desc = desc <- "webapp can be created", {
  local_az_configure(make_testappname(desc))
  local_az_webapp_create()
  expect_equal(
    az_webapp_show()$name,
    az_configure_list()$name
  )
})

test_that(desc = desc <- "deployment slot can be created", {
  local_az_configure(make_testappname(desc))
  local_az_webapp_create()
  suppressMessages(az_webapp_deployment_slot_create(slot = "foo"))
  suppressMessages(az_webapp_deployment_slot_create(slot = "bar"))
  expect_equal(
    az_webapp_deployment_slot_list()$name,
    c("foo", "bar")
  )
})

test_that(desc = desc <- "update works", {
  local_az_configure(make_testappname(desc))
  local_az_webapp_create()
  suppressMessages(az_webapp_update())
  expect_true(az_webapp_show()$clientAffinityEnabled)
  expect_true(az_webapp_show()$httpsOnly)
})

test_that(desc = desc <- "config can be set", {
  local_az_configure(make_testappname(desc))
  local_az_webapp_create()
  suppressMessages(az_webapp_config_set())
  res <- az_webapp_config_show()
  # remove fields with random tan from above
  res <- res[!(names(res) %in% c("id", "name", "publishingUsername"))]
  expect_snapshot_value(res, style = "json2")
})

test_that(desc = desc <- "config container can be set", {
  local_az_configure(make_testappname(desc))
  local_az_webapp_create()
  suppressMessages(az_webapp_config_container_set(
    deployment_container_image_name = "rocker/shiny:4.0.2")
  )
  expect_snapshot_value(az_webapp_config_container_show(), style = "json2")
})

test_that(desc = desc <- "config appsettings can be set", {
  local_az_configure(make_testappname(desc))
  local_az_webapp_create()
  az_webapp_config_appsettings_set()
  expect_snapshot_value(az_webapp_config_appsettings_list(), style = "json2")
})
