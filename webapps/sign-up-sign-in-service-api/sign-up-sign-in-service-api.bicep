param webAppName string
param webAppURLPrefix string
param webAppDomainSuffix string
param aspName string
@secure()
param aspClientId string
param vnetResourceGroup string
param vnetName string
param vnetSubnetName string
param allowSubnetNames string
param buildAgentIPAddress string
param appInsightsResourceGroup string
param appInsightsName string
param environment string
param customTags object
param privateEndpoint object
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')

var deploymentName = 'sign-up-sign-in-service-api-${deploymentDate}'
var defaultTags = {
  ServiceCode: 'TRS'
  ServiceName: 'TRS'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'WEB'
  Location: location
}

module webApp '../../../Defra.Infrastructure.Common/templates/Microsoft.Web/webApps.bicep' = {
  name: deploymentName
  params: {
    webAppName: webAppName
    webAppURLPrefix: webAppURLPrefix
    webAppDomainSuffix: webAppDomainSuffix
    netFrameworkVersion: 'v6.0'
    aspName: aspName
    aspClientId: aspClientId
    vnetResourceGroup: vnetResourceGroup
    vnetName: vnetName
    vnetSubnetName: vnetSubnetName
    allowSubnetNames: allowSubnetNames
    buildAgentIPAddress: buildAgentIPAddress
    appInsightsResourceGroup: appInsightsResourceGroup
    appInsightsName: appInsightsName
    environment: environment
    defaultTags: defaultTags
    customTags: customTags
    privateEndpoint: privateEndpoint
    location: location
    deploymentDate: deploymentDate
  }
}
