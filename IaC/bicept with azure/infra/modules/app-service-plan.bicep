@description('Name of the App Service Plan.')
param name string

@description('Azure region.')
param location string = resourceGroup().location

@description('SKU name: B1 for dev, P1v3 for prod.')
@allowed(['B1', 'B2', 'P1v3', 'P2v3'])
param skuName string = 'B1'

param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: 'linux'
  properties: {
    reserved: true  // required for Linux plans
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
