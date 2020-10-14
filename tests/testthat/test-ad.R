test_that("sp is only created interactively", {
  expect_error(az_ad_sp_create_for_rbac())
})

test_that("scope is composed correctly", {
  local_az_account()
  local_az_configure(name = "foo")
  expect_snapshot_value(scope_down())
})
