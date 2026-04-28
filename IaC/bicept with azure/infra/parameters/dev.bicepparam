using '../main.bicep'

param environment = 'dev'
param location = 'eastus'
param projectName = 'bicepdemo'
param appServicePlanSku = 'B1'
param runtimeStack = 'NODE|20-lts'
