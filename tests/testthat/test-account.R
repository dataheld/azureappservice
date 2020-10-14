test_that("az account works", {
  skip_if_not(shinycaas::is_github_actions() | Sys.getenv("LOGNAME") == "max")
  local_az_account()
  # only default subscription matters here
  expect_equal(az_account_show()$name, "subugoe")
})
