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

### Create an Azure Container Registry (Once)

The easiest and safest way for AAS to retrieve container images is from
Azure's own container registry (ACR).
If you don't already have an instance,
[set up a container registry](https://learn.microsoft.com/en-us/azure/container-registry/).

::: {.alert .alert-info}
There is nothing specifically shiny-related about the required ACR instance,
and any configuration will do.
Consequently, no ARM template is included here.
If your organisation already has an ACR instance,
please use that
or defer to your organisations needs and policies in configuring a new one.
:::

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

### Push `runner` Image to ACR (Every Commit)

Push the image which contains the shiny app (`runner`) to ACR.

```sh
docker push <registry-name>.azurecr.io/<project-name>/runner:production
```

### Create an Azure App Service Plan (Once)

The [Azure App Service plan (ASP)](https://learn.microsoft.com/en-us/azure/app-service/)
is the compute resource running the container with your shiny app.
Loosely,
it is the *host virtual machine (VM)* on which `docker run` is executed.

Create an ASP with Linux as the host operating system.

::: {.alert .alert-info}
Like the ACR instance above,
Shiny places no special demands on the ASP.
The best SKU and other settings depend on your organisations policies
and individual use case.
:::

Contra other Container-as-a-Service (CaaS) offerings,
Azure allows you to run entirely separate (dockerised) web apps
inside *one* ASP, sharing compute resources.
For example, you could run several unrelated shiny apps in the same ASP.

::: {.alert .alert-info}
Hosting several shiny apps on the same ASP can be a cost-effective way
to host shiny,
especially when you expect uncorrelated and limited traffic on each of the apps.

If you deploy several shiny apps to the same ASP,
the apps are isolated in their own docker containers.
For example, if the R session of one shiny app is busy,
the other apps on the same ASP should still be responsive.

However,
these apps and their containers still share the same physical resources,
and high resource use of one app may spill over into another.
Memory usage in particular can be a bottleneck on the lower-powered ASP SKUs;
if one shiny app exhausts the ASP's memory,
other apps may become unavailable.
:::

### Create a Web App (Once per App) {.tabset}

You're now ready to create the (dockerised) web app
which will drive your shiny app.

The easiest way to make sure all the settings are correct is to use the
Azure Resource Manager (ARM) bicep template included with this package (`inst/arm`).

1. Copy `template.bicep` to the repository with your shiny app.
    To avoid `R CMD check` warning messages,
    place it inside `inst/arm`.
2. Copy `template.parameters.json` and replace the values.

#### Local Shell

```sh
az deployment group create \
  --resource-group marketing \
  --template-file inst/arm/template.bicep \
  --parameters inst/arm/template.parameters.json
```

For extra security,
you will have to enter your Azure subscription at the prompt.

#### CI (GitHub Actions)

Use the [arm-deploy](https://github.com/Azure/arm-deploy) GitHub Action
to deploy.
See `.github/workflows/cicd.yaml` for an example.

There's no need to recreate the (identical) app in CI on every commit,
but it's also harmless to do so.
Recreating the app on every commit ensures that the settings are under version
control (infrastructure-as-code).

::: {.alert .alert-warning}
If you want deploy the ARM template from GitHub Actions (recommended),
the app registration created in the above for GitHub Actions
must receive `Contributor` privileges on the resource group
or ASP to which you want to deploy your app.
This extends a fairly elevaned privilege to grant GitHub Actions on Azure.
Make sure to follow
[best practices for information security](https://docs.github.com/en/code-security)
to safeguard your GitHub account.
:::

::: {.alert .alert-info}
Hosting several shiny apps on the same ASP can be a cost-effective way
to host shiny,
especially when you expect uncorrelated and limited traffic on each of the apps.

If you deploy several shiny apps to the same ASP,
the apps are isolated in their own docker containers.
For example, if the R session of one shiny app is busy,
the other apps on the same ASP should still be responsive.

However,
these apps and their containers still share the same physical resources,
and high resource use of one app may spill over into another.
Memory usage in particular can be a bottleneck on the lower-powered ASP SKUs;
if one shiny app exhausts the ASP's memory,
other apps may become unavailable.
:::

### Update the Web App (Every Commit) {.tabset}

To put the latest version of your dockerised shiny app in production,
simply restart the web app;
it will then pull the current image under the appropriate tag.

#### Local Shell

```sh
az webapp restart --name MyWebapp --resource-group MyResourceGroup
```

For example,

```sh
az webapp restart --name dataheld-azureappservice --resource-group marketing
```

#### CI (GitHub Actions)

Give the above created app registration for GitHub Actions write
privileges on the web app using the web apps access control (IAM) settings.
Choose `Contributor` as a role.

You can then run the same command as in your shell;
Azure CLI is already installed on most GitHub runners.

For example:

```yaml
- name: "Restart App"
        run: |
          az webapp restart \
            --name dataheld-azureappservice \
            --resource-group marketing
```

### Visit the Live Shiny App {.tabset}

#### Local (Shell)

For example:

```sh
az webapp browse --name dataheld-azureappservice --resource-group marketing
```

#### CI (GitHub Actions)

Look for the `production` environment in your GitHub repo
to find the URL under which the web app is live.

## Installation

Install the development version from GitHub with:

```r
remotes::install_github("dataheld/azureappservice")
```

You need not take on azureappservice as a runtime dependency (in your `DESCRIPTION`s `Imports` field), because the package is typically only needed during deployment.
Consider adding it as an optional `Suggests` dependency, or add it separately to the compute environment from which you deploy.
