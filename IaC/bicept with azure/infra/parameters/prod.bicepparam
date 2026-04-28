using '../main.bicep'

param environment = 'prod'
param location = 'eastus'
param projectName = 'bicepdemo'
param appServicePlanSku = 'P1v3'
param runtimeStack = 'NODE|20-lts'
