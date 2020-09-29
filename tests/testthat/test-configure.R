test_that("az configure works", {
  old_defaults <- az_configure_list()
  expect_identical(
    az_configure(name = "foo", resource_group = "bar"),
    list(resource_group = "bar", name = "foo")
  )
  expect_identical(
    az_configure_list(),
    list(resource_group = "bar", name = "foo")
  )
  fs::file_delete(".azure/config")
  expect_error(az_configure())
  withr::defer(do.call(az_configure, old_defaults))
})
