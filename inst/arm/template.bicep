param name string
param location string
param hostingPlanName string
param serverFarmResourceGroup string
param linuxFxVersion string
param dockerRegistryUrl string

@secure()
param subscriptionId string

resource name_resource 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: {}
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: dockerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: null
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: null
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      linuxFxVersion: linuxFxVersion
      appCommandLine: ''
      alwaysOn: true
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
    }
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
    clientAffinityEnabled: true
    virtualNetworkSubnetId: null
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    clientCertMode: 'Optional'
  }
}
