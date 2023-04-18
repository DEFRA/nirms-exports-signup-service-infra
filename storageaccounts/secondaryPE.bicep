param name string
param secondaryVNetNAme string
param secondarySubNetNAme string


@description('The arm storage account parameters objects. Parameters are: {name,type,tier,accessTier,supportsHttpsTrafficOnly,kind, releaseContainerName}')
param strgAccount object
param location string
param defaultTags object


resource strgAccount_privateEndpoints_SecondaryName 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: strgAccount.privateEndpoints.SecondaryName
  location: location
  tags: union(defaultTags, strgAccount.privateEndpoints.customTagsSecondary)
  properties: {
    privateLinkServiceConnections: [
      {
        name: strgAccount.privateEndpoints.SecondaryName
        properties: {
          privateLinkServiceId: name
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: '${secondaryVNetNAme}/subnets/${secondarySubNetNAme}'
    }
    customDnsConfigs: []
  }
}
