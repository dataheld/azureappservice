# TODO factor out to ghactions https://github.com/subugoe/AzureAppService/issues/20
#' Get the URL to GitHub Actions for a local repo.
#'
#' @inheritParams gh::gh_tree_remote
#'
#' @keywords internal
#'
#' @export
get_ghactions_url <- function(path = ".") {
  path <- "."
  slug <- gh::gh_tree_remote(path = path)
  res <- httr::parse_url("https://github.com")
  # TODO this probably already exists somewhere ...
  res$path <- do.call(paste, c(slug, "actions", sep = "/"))
  httr::build_url(res)
}
