test_that("az configure works", {
  local_az_configure(name = "foo")
  expect_snapshot_value(az_configure_list())
})
