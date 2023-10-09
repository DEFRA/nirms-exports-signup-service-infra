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
param serviceBusRoleAssignmentsPolicyPrimary object
param serviceBusRoleAssignmentsPolicySecondary object
param secondaryRegionEnvironment string

var deploymentName = 'gc-application-service-function-app-${deploymentDate}'
var secPrincipleID = reference(resourceId(resourceGroup().name,'Microsoft.Web/sites', functionAppName), '2021-01-15', 'full').identity.principalId
var priPrincipleID = reference(resourceId('Microsoft.Web/sites', functionAppName), '2021-01-15', 'full').identity.principalId
var deployToSecondaryRegion = ((toLower(secondaryRegionEnvironment) != 'none') && ((toLower(environment) == 'prd') || (secondaryRegionEnvironment =~ environment)))
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

module roleAssignmentsServiceBusPolicyPrimary '../../../Defra.Infrastructure.Common/templates/Microsoft.Authorization/serviceBusRoleAssignments.bicep' = if (deployToSecondaryRegion){
  name: 'ServiceBusPrimary-${deploymentDate}'
  scope: resourceGroup(serviceBusRoleAssignmentsPolicyPrimary.resourceGroupName)
  params: {
    roleAssignment: serviceBusRoleAssignmentsPolicyPrimary
    appPrincipalId: secPrincipleID
    appName: functionAppName
    appResourceGroupName: resourceGroup().name
  }
  dependsOn: [
    functionApp
  ]
 }

 module roleAssignmentsServiceBusPolicySecondary '../../../Defra.Infrastructure.Common/templates/Microsoft.Authorization/serviceBusRoleAssignments.bicep' = if (deployToSecondaryRegion){
  name: 'ServiceBusPrimary-${deploymentDate}'
  scope: resourceGroup(serviceBusRoleAssignmentsPolicySecondary.resourceGroupName)
  params: {
    roleAssignment: serviceBusRoleAssignmentsPolicySecondary
    appPrincipalId: secPrincipleID
    appName: functionAppName
    appResourceGroupName: resourceGroup().name
  }
  dependsOn: [
    functionApp
  ]
 }
