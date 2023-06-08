if (require("dotenv")) {
  dotenv::load_dot_env()
  message("Loaded environment variables from .env ...")
  options(
    repos = c(
      RSPM = paste0(
        "https://packagemanager.rstudio.com/all/",
        Sys.getenv("RSPM_SNAPSHOT_DATE"),
        "+",
        Sys.getenv("RSPM_SNAPSHOT_QUERY")
      )
    )
  )
  message("Set RSPM snapshot date to ", Sys.getenv("RSPM_SNAPSHOT_DATE"), "...")
} else {
  message(
    "RSPM snapshot date could not be set.",
    "Please install 'dotenv' R package."
  )
}
if (file.exists("~/.Rprofile")) {
  message(
    "Also found user `.Rprofile`, loading ..."
  )
  source("~/.Rprofile")
}
