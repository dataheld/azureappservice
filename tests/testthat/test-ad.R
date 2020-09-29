test_that("sp is only created interactively", {
  expect_error(az_ad_sp_create_for_rbac())
})

test_that("scope is composed correctly", {
  expect_equal(
    scope_down(subscription = "foo", resource_group = "bar", provider = NULL),
    "/subscriptions/foo/resourceGroups/bar"
  )
  expect_equal(
    scope_down(),
    "/subscriptions/f0dd3a37-0a4e-4e7f-9c9b-cb9f60146edc/resourceGroups/hoad/providers/Microsoft.Web/sites/hello-shiny"
  )
})
