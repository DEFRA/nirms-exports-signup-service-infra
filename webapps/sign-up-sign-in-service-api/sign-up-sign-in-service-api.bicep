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
param keyvaultAccessPolicy array
param appConfigurationRoleAssignments array
param location string = resourceGroup().location
param deploymentDate string = utcNow('yyyyMMdd-HHmmss')
param createdDate string = utcNow('yyyy-MM-dd')
param serviceBusRoleAssignmentsPrimary object
param serviceBusRoleAssignmentsSecondary object
param secondaryRegionEnvironment string

var deploymentName = 'sign-up-sign-in-service-api-${deploymentDate}'
var defaultTags = {
  ServiceCode: 'REM'
  ServiceName: 'REM'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'WEB'
  Location: location
}

var configurationServerUri = !empty(appConfigurationRoleAssignments) && contains(first(appConfigurationRoleAssignments),'resourceName')?'https://${first(appConfigurationRoleAssignments).resourceName}.azconfig.io': ''
var secPrincipleID = reference(resourceId(resourceGroup().name,'Microsoft.Web/sites', webAppName), '2021-01-15', 'full').identity.principalId
var priPrincipleID = reference(resourceId('Microsoft.Web/sites', webAppName), '2021-01-15', 'full').identity.principalId
var deployToSecondaryRegion = ((toLower(secondaryRegionEnvironment) != 'none') && ((toLower(environment) == 'prd') || (secondaryRegionEnvironment =~ environment)))

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
    customAppSettings: {
      'ConfigurationServer:Uri': configurationServerUri      
    }
    privateEndpoint: privateEndpoint
    keyvaultAccessPolicy: keyvaultAccessPolicy
    location: location
    deploymentDate: deploymentDate
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
    webApp
  ]
}

module roleAssignmentsServiceBusSecondary '../../../Defra.Infrastructure.Common/templates/Microsoft.Authorization/serviceBusRoleAssignments.bicep' = if (deployToSecondaryRegion) {
  name: 'ServiceBusPrimary-${deploymentDate}'
  scope: resourceGroup(serviceBusRoleAssignmentsPrimary.resourceGroupName)
  params: {
    roleAssignment: serviceBusRoleAssignmentsPrimary
    appPrincipalId: secPrincipleID
    appName: functionAppName
    appResourceGroupName: resourceGroup().name
  }
  dependsOn: [
    webApp
  ]
}


