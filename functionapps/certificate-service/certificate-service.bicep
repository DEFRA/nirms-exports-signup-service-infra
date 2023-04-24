param functionAppName string
param location string = resourceGroup().location
param customTags object
param functionAppURLPrefix string
param functionAppDomainSuffix string
param aspName string
param createdDate string = utcNow('yyyy-MM-dd')
param environment string
param appInsightsName string
param appInsightsResourceGroup string
param vnetResourceGroup string
param vnetName string
param vnetSubnetName string
param functionApplogStorageName string
param functionApplogStorageResourceGroup string
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param buildAgentIPAddress string
param privateEndpoint object

var deploymentName = 'gc-application-service-function-app-${deploymentDate}'
var defaultTags = {
  ServiceCode: 'TRE'
  ServiceName: 'TRE'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'WEB'
  Location:location
}

module functionApp '../../../Defra.Infrastructure.Common/templates/Microsoft.Web/functionApps.bicep' = {
  name: deploymentName
  params: {
    functionAppName:functionAppName
    location:location
    defaultTags:defaultTags
    customTags:customTags
    functionAppURLPrefix:functionAppURLPrefix
    functionAppDomainSuffix:functionAppDomainSuffix
    aspName:aspName
    vnetResourceGroup:vnetResourceGroup
    vnetName:vnetName
    vnetSubnetName:vnetSubnetName
    functionApplogStorageName:functionApplogStorageName
    functionApplogStorageResourceGroup:functionApplogStorageResourceGroup
    appInsightsName:appInsightsName
    appInsightsResourceGroup:appInsightsResourceGroup
    buildAgentIPAddress:buildAgentIPAddress
    environment:environment
    netFrameworkVersion:'v6.0'
    functionExtensionVersion:'~4'
    privateEndpoint: privateEndpoint
  }
}