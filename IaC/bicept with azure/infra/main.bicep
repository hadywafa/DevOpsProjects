targetScope = 'subscription'

@description('Deployment environment.')
@allowed(['dev', 'prod'])
param environment string

@description('Primary Azure region.')
param location string = 'eastus'

@description('Short project identifier used in resource names (≤10 chars, lowercase).')
@maxLength(10)
param projectName string = 'bicepdemo'

@description('App Service Plan SKU.')
@allowed(['B1', 'B2', 'P1v3', 'P2v3'])
param appServicePlanSku string = 'B1'

@description('Linux runtime stack, e.g. NODE|20-lts or DOTNETCORE|8.0.')
param runtimeStack string = 'NODE|20-lts'

// ── Derived names ──────────────────────────────────────────────────────────────
var resourceGroupName = 'rg-${projectName}-${environment}-${location}'
var appServicePlanName = 'asp-${projectName}-${environment}'
// Web App name must be globally unique
var webAppName = '${projectName}-${environment}-${uniqueString(subscription().subscriptionId, environment)}'

var tags = {
  environment: environment
  project: projectName
  managedBy: 'bicep'
}

// ── Resource Group ─────────────────────────────────────────────────────────────
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ── App Service Plan (module) ──────────────────────────────────────────────────
module appPlan 'modules/app-service-plan.bicep' = {
  name: 'deploy-asp'
  scope: rg               // deploy into the RG created above
  params: {
    name: appServicePlanName
    location: location
    skuName: appServicePlanSku
    tags: tags
  }
}

// ── Web App (module) — receives plan ID from previous module output ────────────
module webApp 'modules/web-app.bicep' = {
  name: 'deploy-webapp'
  scope: rg
  params: {
    name: webAppName
    location: location
    appServicePlanId: appPlan.outputs.id   // output chaining — no hardcoding
    linuxFxVersion: runtimeStack
    tags: tags
  }
}

// ── Outputs ────────────────────────────────────────────────────────────────────
output resourceGroupName string = rg.name
output appServicePlanId string = appPlan.outputs.id
output webAppName string = webApp.outputs.name
output webAppUrl string = webApp.outputs.url
