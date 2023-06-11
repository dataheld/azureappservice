# azureappservice

azureappservice lets you manage [Azure App Service (AAS)](https://azure.microsoft.com/en-us/services/app-service/), a Platform-as-a-Service (PaaS) and Container-as-a-Service (CaaS) from Microsoft.

You can use it to deploy a containerised shiny app to the cloud.

::: {.alert .alert-warning}
Cloud services such as AAS can rack up unexpected bills,
if you don't
[manage costs carefully](https://learn.microsoft.com/en-us/azure/cost-management-billing/).
If you are not familiar with cloud services,
or would like a solution with a simpler way to control costs,
consider Posit's [shinyapps.io](https://www.shinyapps.io).
:::

## Prerequisites

- A **dockerised shiny app**.
    You must ship your shiny app inside a docker container,
    where the app has all the dependencies it needs to run.
    You can use [muggle](https://maxheld.de/muggle/) (recommended),
    [rocker/shiny](https://hub.docker.com/r/rocker/shiny)
    or roll your own.
- An **azure account** with an active subscription.

## Usage

You can deploy a shiny app to AAS from CI (GitHub Actions),
or using your local computer (Shell).

Deploying from CI is recommended to let you reap the benefits of fully
automated continuous integration and continuous delivery (CI/CD).
If you deploy from CI, every `git push` to the appropriate branch
will be deployed to production.

You can use your local shell as backstop or
for a quicker turnaround during debugging.

### Log In to Azure {.tabset}

You first need to authenticate into Azure to be able to make changes to Azure resources.

#### Local (Shell)

[Sign in interactively](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
with Azure CLI.

```sh
az login
```

#### CI (GitHub Actions)

Use the [Azure Login GitHub Action](https://github.com/marketplace/actions/azure-login).
For maximum security and convenience,
use OpenID Connect (OIDC) based Federated Identity Credentials
(or Workflow Identify Federation, WIF).

To authenticate via WIF, you need to complete two steps on the Azure side:

1. [Create an *app registration* for GitHub](https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation-create-trust-user-assigned-managed-identity?pivots=identity-wif-mi-methods-azp).
    You only need *one* app registration for all your deployments from GitHub Actions to Azure.
    (Though there might be a limit of 20 federated credentials for each app registration).
1. For each combination of GitHub organisation/repository (`octouser/octoproject`) and environment (say, `production`) create one [federated credential](https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation-create-trust-user-assigned-managed-identity?pivots=identity-wif-mi-methods-azp).

    The values for organization/repository and environment
    must match those in the GitHub repo from which you want to deploy.
    You can add several of these federated credentials;
    without storing additional secrets on GitHub.
    All federated credentials on the same app registration
    use the same secrets as created in the above.

::: {.alert .alert-info}
At this point in the setup,
the app you registered in the above has *no* assigned roles
and cannot do anything on Azure.
As a result,
you may get this error message if you run the Azure Login GitHub Action:

> ```sh
> ERROR: (SubscriptionNotFound) The subscription '***' could not be found.`
> Code: SubscriptionNotFound
> ```

This will be fixed below,
where you'll give the app registration the necessary privileges.

If you want to run the Azure Login GitHub Action as is,
pass the `allow-no-subscriptions: true` argument.
:::

### Create an Azure Container Registry (One-Time)

The easiest and safest way for AAS to retrieve container images is from
Azure's own container registry (ACR).
If you don't already have an instance,
[set up a container registry](https://learn.microsoft.com/en-us/azure/container-registry/).

### Login to ACR {.tabset}

Log in to ACR, leveraging the above login to Azure.
This step is necessary to allow `docker` to speak to your ACR instance.

#### Local (Shell)

No extra step necessary.

#### CI (GitHub Actions)

If you're using OIDC (recommended) as per the above,
give your app `AcrPush` privileges on your registry using Azure's access control.

```sh
az acr login --name <registry-name>
```

### Push `runner` Image to ACR

Push the image which contains the shiny app (`runner`) to ACR.

```sh
docker push <registry-name>.azurecr.io/<project-name>/runner:production
```

## Installation

Install the development version from GitHub with:

```r
remotes::install_github("dataheld/azureappservice")
```

You need not take on azureappservice as a runtime dependency (in your `DESCRIPTION`s `Imports` field), because the package is typically only needed during deployment.
Consider adding it as an optional `Suggests` dependency, or add it separately to the compute environment from which you deploy.
