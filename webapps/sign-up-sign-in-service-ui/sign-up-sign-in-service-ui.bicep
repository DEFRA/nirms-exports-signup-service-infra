param webAppName string
param webAppURLPrefix string
param webAppDomainSuffix string
param aspName string
param vnetResourceGroup string
param vnetName string
param vnetSubnetName string
param allowSubnetIds string
param buildAgentIPAddress string
param appInsightsResourceGroup string
param appInsightsName string
param privateEndpoint object
param environment string
param customTags object
param appConfigurationRoleAssignments array
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param keyvaultAccessPolicy array

var deploymentName = 'sign-up-sign-in-service-ui-${deploymentDate}'
var defaultTags = {
  ServiceCode: 'TRS'
  ServiceName: 'TRS'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'WEB'
  Location: location
}

var configurationServerUri = !empty(appConfigurationRoleAssignments) && contains(first(appConfigurationRoleAssignments),'resourceName')?'https://${first(appConfigurationRoleAssignments).resourceName}.azconfig.io': ''

module webApp '../../../Defra.Infrastructure.Common/templates/Microsoft.Web/webApps.bicep' = {
  name: deploymentName
  params: {
    webAppName: webAppName
    webAppURLPrefix: webAppURLPrefix
    webAppDomainSuffix: webAppDomainSuffix
    netFrameworkVersion: 'v6.0'
    aspName: aspName
    vnetResourceGroup: vnetResourceGroup
    vnetName: vnetName
    vnetSubnetName: vnetSubnetName
    allowSubnetIds: allowSubnetIds
    buildAgentIPAddress: buildAgentIPAddress
    appInsightsResourceGroup: appInsightsResourceGroup
    appInsightsName: appInsightsName
    privateEndpoint: privateEndpoint
    environment: environment
    enableADAuthentication : false
    defaultTags: defaultTags
    customTags: customTags
    customAppSettings: {
      'ConfigurationServer:Uri': configurationServerUri      
    }
    webSocketsEnabled: true
    appConfigurationRoleAssignments: appConfigurationRoleAssignments
    location: location
    deploymentDate: deploymentDate
    keyvaultAccessPolicy: keyvaultAccessPolicy
  }
}
