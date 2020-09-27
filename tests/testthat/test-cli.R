test_that("cli wrapper works", {
  expect_invisible(az_cli_run("version"))
  checkmate::expect_list(az_cli_run("version"))
})
