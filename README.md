# AzureAppService

AzureAppService lets you manage [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/), a Platform-as-a-Service (PaaS) and Container-as-a-Service (CaaS) from Microsoft.

You can use it to deploy a containerised shiny app to the cloud.

## Installation

Install the development version from GitHub with:

```r
remotes::install_github("maxheld83/AzureAppService")
```

You need not take on AzureAppService as a runtime dependency (in your `DESCRIPTION`s `Imports` field), because the package is typically only needed during deployment.
Consider adding it as an optional `Suggests` dependency, or add it separately to the compute environment from which you deploy.
