# AzureAppService

<!-- badges: start -->
[![Main](https://github.com/subugoe/AzureAppService/workflows/.github/workflows/main.yaml/badge.svg)](https://github.com/subugoe/AzureAppService/actions)
[![Codecov test coverage](https://codecov.io/gh/subugoe/AzureAppService/branch/master/graph/badge.svg)](https://codecov.io/gh/subugoe/AzureAppService?branch=master)
[![CRAN status](https://www.r-pkg.org/badges/version/AzureAppService)](https://CRAN.R-project.org/package=AzureAppService)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

AzureAppService lets you manage [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/), a Platform-as-a-Service (PaaS) and Container-as-a-Service (CaaS) from Microsoft.
You can deploy a containerised shiny app to the cloud using some simple wrappers.

Contra its name, the package is not (yet) a complete client to Azure App Service, but only covers the commands relevant to deploying a shiny app to [Web App for Containers](https://azure.microsoft.com/en-us/services/app-service/containers/), the CaaS product of Azure App Service.

The package wraps the [Azure CLI](https://docs.microsoft.com/en-us/cli/) rather than talking directly with the [Azure Resource Manager Rest API](https://docs.microsoft.com/en-us/rest/api/resources) via the [AzureRMR](https://github.com/Azure/AzureRMR) package (logged in [#2](https://github.com/subugoe/AzureAppService/issues/2)).


## Installation

Install the development version from GitHub with:

```r
remotes::install_github("subugoe/AzureAppService")
```

You need not take on AzureAppService as a runtime dependency (in your `DESCRIPTION`s `Imports` field), because the package is typically only needed during deployment.
Consider adding it as an optional `Suggests` dependency, or add it separately to the compute environment from which you deploy.


## System Requirements

This package calls the [Microsoft Azure Command-Line Interface (CLI)](https://docs.microsoft.com/en-us/cli/).
It does not (yet) talk directly with the [Azure Resource Manager Rest API](https://docs.microsoft.com/en-us/rest/api/resources) via the [AzureRMR](https://github.com/Azure/AzureRMR) package (logged in [#2](https://github.com/subugoe/AzureAppService/issues/2)).

To deploy to Azure, you need to [install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) any machine from which you want to deploy your shiny app.
There's no need to install the Azure CLI into your *production* image; you only need it at deploy time.
If you only deploy from GitHub Actions (recommended) you do not need to install anything; the Azure CLI is [included](https://docs.github.com/en/actions/reference/software-installed-on-github-hosted-runners) in all GitHub-hosted runners.
