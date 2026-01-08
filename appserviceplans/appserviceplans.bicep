param createdDate string = utcNow('yyyy-MM-dd')
param environment string
param gcUIASP object
param gcBackendAppsASP01 object
param location string = resourceGroup().location
param gcFuntionAppsASP01 object

var defaultTags = {
  ServiceCode: 'REM'
  ServiceName: 'REM'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'WEB'
  Location: location
}

resource gcServiceASPResource 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: gcUIASP.name
  location: location
  tags: union(defaultTags, gcUIASP.customTags)
  sku: {    
    name: gcUIASP.sku.name
    tier: gcUIASP.sku.tier
    size: gcUIASP.sku.size
    family: gcUIASP.sku.family
    capacity: gcUIASP.sku.capacity    
  }
  properties: {
    perSiteScaling: false
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    maximumElasticWorkerCount: gcUIASP.autoscaleSettings.maxcapacity
    elasticScaleEnabled: true
  }
}

resource gcBackendAppsASP01Resource 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: gcBackendAppsASP01.name
  location: location
  tags: union(defaultTags, gcBackendAppsASP01.customTags)
  sku: {    
    name: gcBackendAppsASP01.sku.name
    tier: gcBackendAppsASP01.sku.tier
    size: gcBackendAppsASP01.sku.size
    family: gcBackendAppsASP01.sku.family
    capacity: gcBackendAppsASP01.sku.capacity    
  }
  properties: {
    perSiteScaling: false
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    maximumElasticWorkerCount: gcBackendAppsASP01.autoscaleSettings.maxcapacity
    elasticScaleEnabled: true
  }
}
resource gcFuntionAppsASP01Resource 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: gcFuntionAppsASP01.name
  location: location
  tags: union(defaultTags, gcFuntionAppsASP01.customTags)
  sku: {    
    name: gcFuntionAppsASP01.sku.name
    tier: gcFuntionAppsASP01.sku.tier
    size: gcFuntionAppsASP01.sku.size
    family: gcFuntionAppsASP01.sku.family
    capacity: gcFuntionAppsASP01.sku.capacity    
  }
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 10
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    elasticScaleEnabled: true
  }
}
