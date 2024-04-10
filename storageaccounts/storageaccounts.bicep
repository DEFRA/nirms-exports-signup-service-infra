@description('The Application service storage account parameters objects. Parameters are: {name,type,tier,accessTier,supportsHttpsTrafficOnly,kind, releaseContainerName}')
param strgApplicationService01 object

@description('The tradeVnetInfra parameters object.')
param tradeVnetInfra object

@description('The resource groups paramter object.{}')
param resourceGroups object
param privateLinkDnsZoneNameStorage string
param privateDnsResourceGroups object
param privateEndpointSecondaryResourceGroupLocation string
param secondaryRegionEnvironment string
param environment string
param createdDate string = utcNow('yyyy-MM-dd')
param location string = resourceGroup().location
param sqlServerName string

var defaultTags = {
  ServiceCode: 'GC'
  ServiceName: 'GC'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'STORAGE'
  location:location
}

var deployToSecondaryRegion = ((toLower(environment) == 'prd') || (secondaryRegionEnvironment =~ environment))
var storageBlobContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var uniqueRoleGuid = guid(strgApplicationService01Resource::blobProperties::container.id, storageBlobContributor, sqlServer.id)

resource strgApplicationService01Resource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: toLower(strgApplicationService01.name)
  location: location
  tags: union(defaultTags,  strgApplicationService01.customTags)
  kind: strgApplicationService01.kind
  sku: {
    name: strgApplicationService01.type
  }
  properties: {
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    accessTier: strgApplicationService01.accessTier
    supportsHttpsTrafficOnly: strgApplicationService01.supportsHttpsTrafficOnly
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
    }
  }
  resource blobProperties 'blobServices@2022-05-01' = {
    name: 'default'
    properties: {
      deleteRetentionPolicy: {
        days: 7
        enabled: true
      }  
    }
    resource container 'containers@2022-09-01' = {
      name: 'datasync'
      properties: {
        publicAccess: 'None'
      }
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2020-02-02-preview' existing = {
  name: sqlServerName
  scope: resourceGroup(resourceGroups.sqlServerRgName)
}

resource roleAssignmentsDataSync 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: uniqueRoleGuid
  properties: {
    roleDefinitionId: storageBlobContributor
    principalId: sqlServer.identity.principalId
    principalType: 'ServicePrincipal'
  }
  scope: strgApplicationService01Resource::blobProperties::container
  dependsOn: [
    strgApplicationService01Resource
  ]
}

resource strgApplicationService01_privateEndpoints_primaryName 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: strgApplicationService01.privateEndpoints.primaryName
  location: location
  tags: union(defaultTags, strgApplicationService01.privateEndpoints.customTagsPrimary)
  properties: {
    privateLinkServiceConnections: [
      {
        name: strgApplicationService01.privateEndpoints.primaryName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Storage/storageAccounts', strgApplicationService01.name)
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: '${resourceId(resourceGroups.tradeVnetRgName, 'Microsoft.Network/virtualNetworks', tradeVnetInfra.name)}/subnets/${tradeVnetInfra.subnets.peSubnetName}'
    }
    customDnsConfigs: []
  }
  dependsOn: [
    strgApplicationService01Resource
  ]
}

module strgApplicationService01_name_secondaryPE './secondaryPE.bicep' = if (deployToSecondaryRegion) {
  name: 'gc-sa-applicationService01-secondaryPE'
  scope: resourceGroup(resourceGroups.secondaryRgName)
  params: {
    name: resourceId('Microsoft.Storage/storageAccounts', strgApplicationService01.name)
    secondaryVNetNAme: resourceId(resourceGroups.tradeSecondaryVnetRgName, 'Microsoft.Network/virtualNetworks', tradeVnetInfra.secondaryName)
    secondarySubNetNAme:tradeVnetInfra.subnets.peSecondarySubnetName
    defaultTags: defaultTags
    strgAccount: strgApplicationService01
    location: privateEndpointSecondaryResourceGroupLocation
    
  }
  dependsOn: [
    strgApplicationService01Resource
  ]
}

output privateEndpointDNSRecords array = [
  {
    zone: privateLinkDnsZoneNameStorage
    record: toLower(strgApplicationService01.name)
    resourceGroup: privateDnsResourceGroups.primary
    id: strgApplicationService01_privateEndpoints_primaryName.id
  }
  {
    zone: privateLinkDnsZoneNameStorage
    record: toLower(strgApplicationService01.name)
    resourceGroup: privateDnsResourceGroups.secondary
    id: (deployToSecondaryRegion ? resourceId(resourceGroups.secondaryRgName, 'Microsoft.Network/privateEndpoints', strgApplicationService01.privateEndpoints.SecondaryName) : '')
  }  
]
