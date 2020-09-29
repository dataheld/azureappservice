test_that("login errors out in non-interactive mode", {
  expect_error(az_login())
})
