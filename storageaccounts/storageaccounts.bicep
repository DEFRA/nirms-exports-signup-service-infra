@description('The Application service storage account parameters objects. Parameters are: {name,type,tier,accessTier,supportsHttpsTrafficOnly,kind, releaseContainerName}')
param strgApplicationService01 object

@description('The Trade Service storage account parameters objects. Parameters are: {name,type,tier,accessTier,supportsHttpsTrafficOnly,kind, releaseContainerName}')
param strgTradeService01 object

@description('The Certificate Service storage account parameters objects. Parameters are: {name,type,tier,accessTier,supportsHttpsTrafficOnly,kind, releaseContainerName}')
param strgCertificateService01 object

@description('The Notification Service storage account parameters objects. Parameters are: {name,type,tier,accessTier,supportsHttpsTrafficOnly,kind, releaseContainerName}')
param strgNotificationService01 object

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
  }
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

resource strgTradeService01Resource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: toLower(strgTradeService01.name)
  location: location
  tags: union(defaultTags,  strgTradeService01.customTags)
  kind: strgTradeService01.kind
  sku: {
    name: strgTradeService01.type
  }
  properties: {
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    accessTier: strgTradeService01.accessTier
    supportsHttpsTrafficOnly: strgTradeService01.supportsHttpsTrafficOnly
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
  }
}

resource strgTradeService01_privateEndpoints_primaryName 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: strgTradeService01.privateEndpoints.primaryName
  location: location
  tags: union(defaultTags, strgTradeService01.privateEndpoints.customTagsPrimary)
  properties: {
    privateLinkServiceConnections: [
      {
        name: strgTradeService01.privateEndpoints.primaryName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Storage/storageAccounts', strgTradeService01.name)
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
    strgTradeService01Resource
  ]
}

module strgTradeService01_name_secondaryPE './secondaryPE.bicep' = if (deployToSecondaryRegion) {
  name: 'gc-sa-tradeService01-secondaryPE'
  scope: resourceGroup(resourceGroups.secondaryRgName)
  params: {
    name: resourceId('Microsoft.Storage/storageAccounts', strgTradeService01.name)
    secondaryVNetNAme: resourceId(resourceGroups.tradeSecondaryVnetRgName, 'Microsoft.Network/virtualNetworks', tradeVnetInfra.secondaryName)
    secondarySubNetNAme:tradeVnetInfra.subnets.peSecondarySubnetName
    defaultTags: defaultTags
    strgAccount: strgTradeService01
    location: privateEndpointSecondaryResourceGroupLocation
    
  }
  dependsOn: [
    strgTradeService01Resource
  ]
}

resource strgCertificateService01Resource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: toLower(strgCertificateService01.name)
  location: location
  tags: union(defaultTags,  strgCertificateService01.customTags)
  kind: strgCertificateService01.kind
  sku: {
    name: strgCertificateService01.type
  }
  properties: {
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    accessTier: strgCertificateService01.accessTier
    supportsHttpsTrafficOnly: strgCertificateService01.supportsHttpsTrafficOnly
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
  }
}

resource strgCertificateService01_privateEndpoints_primaryName 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: strgCertificateService01.privateEndpoints.primaryName
  location: location
  tags: union(defaultTags, strgCertificateService01.privateEndpoints.customTagsPrimary)
  properties: {
    privateLinkServiceConnections: [
      {
        name: strgCertificateService01.privateEndpoints.primaryName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Storage/storageAccounts', strgCertificateService01.name)
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
    strgCertificateService01Resource
  ]
}

module strgCertificateService01_name_secondaryPE './secondaryPE.bicep' = if (deployToSecondaryRegion) {
  name: 'gc-sa-certificateService01-secondaryPE'
  scope: resourceGroup(resourceGroups.secondaryRgName)
  params: {
    name: resourceId('Microsoft.Storage/storageAccounts', strgCertificateService01.name)
    secondaryVNetNAme: resourceId(resourceGroups.tradeSecondaryVnetRgName, 'Microsoft.Network/virtualNetworks', tradeVnetInfra.secondaryName)
    secondarySubNetNAme:tradeVnetInfra.subnets.peSecondarySubnetName
    defaultTags: defaultTags
    strgAccount: strgCertificateService01
    location: privateEndpointSecondaryResourceGroupLocation
    
  }
  dependsOn: [
    strgCertificateService01Resource
  ]
}

resource strgNotificationService01Resource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: toLower(strgNotificationService01.name)
  location: location
  tags: union(defaultTags,  strgNotificationService01.customTags)
  kind: strgNotificationService01.kind
  sku: {
    name: strgNotificationService01.type
  }
  properties: {
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    accessTier: strgNotificationService01.accessTier
    supportsHttpsTrafficOnly: strgNotificationService01.supportsHttpsTrafficOnly
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
  }
}

resource strgNotificationService01_privateEndpoints_primaryName 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: strgNotificationService01.privateEndpoints.primaryName
  location: location
  tags: union(defaultTags, strgNotificationService01.privateEndpoints.customTagsPrimary)
  properties: {
    privateLinkServiceConnections: [
      {
        name: strgNotificationService01.privateEndpoints.primaryName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Storage/storageAccounts', strgNotificationService01.name)
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
    strgNotificationService01Resource
  ]
}

module strgNotificationService01_name_secondaryPE './secondaryPE.bicep' = if (deployToSecondaryRegion) {
  name: 'gc-sa-notificationService01-secondaryPE'
  scope: resourceGroup(resourceGroups.secondaryRgName)
  params: {
    name: resourceId('Microsoft.Storage/storageAccounts', strgNotificationService01.name)
    secondaryVNetNAme: resourceId(resourceGroups.tradeSecondaryVnetRgName, 'Microsoft.Network/virtualNetworks', tradeVnetInfra.secondaryName)
    secondarySubNetNAme:tradeVnetInfra.subnets.peSecondarySubnetName
    defaultTags: defaultTags
    strgAccount: strgNotificationService01
    location: privateEndpointSecondaryResourceGroupLocation
    
  }
  dependsOn: [
    strgNotificationService01Resource
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
  {
    zone: privateLinkDnsZoneNameStorage
    record: toLower(strgTradeService01.name)
    resourceGroup: privateDnsResourceGroups.primary
    id: strgTradeService01_privateEndpoints_primaryName.id
  }
  {
    zone: privateLinkDnsZoneNameStorage
    record: toLower(strgTradeService01.name)
    resourceGroup: privateDnsResourceGroups.secondary
    id: (deployToSecondaryRegion ? resourceId(resourceGroups.secondaryRgName, 'Microsoft.Network/privateEndpoints', strgTradeService01.privateEndpoints.SecondaryName) : '')
  }
  {
    zone: privateLinkDnsZoneNameStorage
    record: toLower(strgCertificateService01.name)
    resourceGroup: privateDnsResourceGroups.primary
    id: strgCertificateService01_privateEndpoints_primaryName.id
  }
  {
    zone: privateLinkDnsZoneNameStorage
    record: toLower(strgCertificateService01.name)
    resourceGroup: privateDnsResourceGroups.secondary
    id: (deployToSecondaryRegion ? resourceId(resourceGroups.secondaryRgName, 'Microsoft.Network/privateEndpoints', strgCertificateService01.privateEndpoints.SecondaryName) : '')
  }
  {
    zone: privateLinkDnsZoneNameStorage
    record: toLower(strgNotificationService01.name)
    resourceGroup: privateDnsResourceGroups.primary
    id: strgNotificationService01_privateEndpoints_primaryName.id
  }
  {
    zone: privateLinkDnsZoneNameStorage
    record: toLower(strgNotificationService01.name)
    resourceGroup: privateDnsResourceGroups.secondary
    id: (deployToSecondaryRegion ? resourceId(resourceGroups.secondaryRgName, 'Microsoft.Network/privateEndpoints', strgNotificationService01.privateEndpoints.SecondaryName) : '')
  }
  
]
