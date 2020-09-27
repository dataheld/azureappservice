
# AzureAppService

<!-- badges: start -->
[![Main](https://github.com/subugoe/AzureAppService/workflows/.github/workflows/main.yaml/badge.svg)](https://github.com/subugoe/AzureAppService/actions)
[![Codecov test coverage](https://codecov.io/gh/subugoe/AzureAppService/branch/master/graph/badge.svg)](https://codecov.io/gh/subugoe/AzureAppService?branch=master)
[![R build status](https://github.com/subugoe/AzureAppService/workflows/R-CMD-check/badge.svg)](https://github.com/subugoe/AzureAppService/actions)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

AzureAppService lets you deploy a shiny app to [Microsoft Azure Web Apps for Containers](https://azure.microsoft.com/en-us/services/app-service/containers/).
Contra its name, the package does not cover all of Azure App Service, but only the part relevant to host shiny apps.

## System Requirements

This package calls the [Microsoft Azure](https://azure.microsoft.com/) Command-Line Interface (CLI).
To deploy to Azure, you need to [install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) any machine from which you want to deploy your shiny app.
There's no need to install the Azure CLI into your *production* image; you only need it at deploy time.
If you only deploy from GitHub Actions (recommended) you do not need to install anything; the Azure CLI is [included](https://docs.github.com/en/actions/reference/software-installed-on-github-hosted-runners) in all GitHub-hosted runners.
