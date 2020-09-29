test_that("cli commands work", {
  expect_invisible(az_cli_run("version"))
  checkmate::expect_list(az_cli_run(cmd = "version", opt = "--verbose"))
})
