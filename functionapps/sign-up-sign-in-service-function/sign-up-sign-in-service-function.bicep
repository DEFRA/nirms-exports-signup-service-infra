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
param serviceBusRoleAssignmentsPrimary object
param serviceBusRoleAssignmentsSecondary object
param secondaryRegionEnvironment string
param appConfigurationRoleAssignments array

var deploymentName = 'gc-application-service-function-app-${deploymentDate}'
var secPrincipleID = reference(resourceId(resourceGroup().name,'Microsoft.Web/sites', functionAppName), '2021-01-15', 'full').identity.principalId
var priPrincipleID = reference(resourceId('Microsoft.Web/sites', functionAppName), '2021-01-15', 'full').identity.principalId
var deployToSecondaryRegion = ((toLower(secondaryRegionEnvironment) != 'none') && ((toLower(environment) == 'prd') || (secondaryRegionEnvironment =~ environment)))
var defaultTags = {
  ServiceCode: 'REM'
  ServiceName: 'REM'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'WEB'
  Location:location
}

var configurationServerUri = !empty(appConfigurationRoleAssignments) && contains(first(appConfigurationRoleAssignments),'resourceName')?'https://${first(appConfigurationRoleAssignments).resourceName}.azconfig.io': ''
var customAppSettings = {
  'ConfigurationServer:Uri': configurationServerUri
  'FUNCTIONS_INPROC_NET8_ENABLED' : 1
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
    netFrameworkVersion:'v8.0'
    functionExtensionVersion:'~4'
    privateEndpoint: privateEndpoint
    customAppSettings: customAppSettings
    appConfigurationRoleAssignments: appConfigurationRoleAssignments
  }
}

module roleAssignmentsServiceBusPrimary '../../../Defra.Infrastructure.Common/templates/Microsoft.Authorization/serviceBusRoleAssignments.bicep' =  {
  name: 'ServiceBusPrimary-${deploymentDate}'
  scope: resourceGroup(serviceBusRoleAssignmentsPrimary.resourceGroupName)
  params: {
    roleAssignment: serviceBusRoleAssignmentsPrimary
    appPrincipalId: priPrincipleID
    appName: functionAppName
    appResourceGroupName: resourceGroup().name
  }
  dependsOn: [
   functionApp
  ]
}

module roleAssignmentsServiceBusSecondary '../../../Defra.Infrastructure.Common/templates/Microsoft.Authorization/serviceBusRoleAssignments.bicep' = if (deployToSecondaryRegion){
 name: 'ServiceBusPrimary-${deploymentDate}'
 scope: resourceGroup(serviceBusRoleAssignmentsSecondary.resourceGroupName)
 params: {
   roleAssignment: serviceBusRoleAssignmentsSecondary
   appPrincipalId: secPrincipleID
   appName: functionAppName
   appResourceGroupName: resourceGroup().name
 }
 dependsOn: [
   functionApp
 ]
}

