@description('Name of the Web App (must be globally unique).')
param name string

@description('Azure region.')
param location string = resourceGroup().location

@description('Resource ID of the App Service Plan to host this app.')
param appServicePlanId string

@description('Linux FX version string, e.g. "NODE|20-lts" or "DOTNETCORE|8.0".')
param linuxFxVersion string = 'NODE|20-lts'

param tags object = {}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true          // redirect HTTP → HTTPS
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      ftpsState: 'Disabled'  // disable FTP completely
      minTlsVersion: '1.2'
      alwaysOn: true         // keep warm (not available on free/shared SKUs)
      http20Enabled: true
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
  }
}

output id string = webApp.id
output name string = webApp.name
output defaultHostName string = webApp.properties.defaultHostName
output url string = 'https://${webApp.properties.defaultHostName}'
