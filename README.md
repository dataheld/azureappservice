# AzureAppService

AzureAppService lets you manage [Azure App Service](https://azure.microsoft.com/en-us/services/app-service/), a Platform-as-a-Service (PaaS) and Container-as-a-Service (CaaS) from Microsoft.

You can use it to deploy a containerised shiny app to the cloud.

## Usage

### Prerequisites

- A **dockerised shiny app**.
    You must ship your shiny app inside a docker container,
    where the app has all the dependencies it needs to run.
    You can use [muggle](https://maxheld.de/muggle/) (recommended),
    [rocker/shiny](https://hub.docker.com/r/rocker/shiny)
    or roll your own.
- An **azure account** with an active subscription.

## Installation

Install the development version from GitHub with:

```r
remotes::install_github("maxheld83/AzureAppService")
```

You need not take on AzureAppService as a runtime dependency (in your `DESCRIPTION`s `Imports` field), because the package is typically only needed during deployment.
Consider adding it as an optional `Suggests` dependency, or add it separately to the compute environment from which you deploy.
