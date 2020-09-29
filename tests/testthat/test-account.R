test_that("az account works", {
  checkmate::expect_subset(
    x = "subugoe",
    choices = az_account()$name,
    empty.ok = FALSE
  )
})
