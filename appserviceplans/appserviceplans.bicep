param createdDate string = utcNow('yyyy-MM-dd')
param environment string
param gcUIASP object
param gcBackendAppsASP01 object
param location string = resourceGroup().location

var defaultTags = {
  ServiceCode: 'TRS'
  ServiceName: 'TRS'
  ServiceType: 'LOB'
  CreatedDate: createdDate
  Environment: environment
  Tier: 'WEB'
  Location: location
}

resource gcServiceASPResource 'Microsoft.Web/serverfarms@2020-06-01' = {
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
  }
}

resource gcUIASP_name_setting 'Microsoft.Insights/autoscalesettings@2015-04-01' = {
  name: '${gcUIASP.name}-setting'
  location: location
  properties: {
    profiles: [
      {
        name: 'DefaultAutoscaleProfile'
        capacity: {
          minimum: gcUIASP.autoscaleSettings.mincapacity
          maximum: gcUIASP.autoscaleSettings.maxcapacity
          default: gcUIASP.autoscaleSettings.defaultcapacity
        }
        rules: [
          {
            metricTrigger: {
              metricName: gcUIASP.autoscaleSettings.metrics[0].name
              metricNamespace: ''
              metricResourceUri: gcServiceASPResource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: gcUIASP.autoscaleSettings.metrics[0].thresholdToScaleOut
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1M'
            }
          }
          {
            metricTrigger: {
              metricName: gcUIASP.autoscaleSettings.metrics[1].name
              metricNamespace: ''
              metricResourceUri: gcServiceASPResource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: gcUIASP.autoscaleSettings.metrics[1].thresholdToScaleOut
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1M'
            }
          }
          {
            metricTrigger: {
              metricName: gcUIASP.autoscaleSettings.metrics[0].name
              metricNamespace: ''
              metricResourceUri: gcServiceASPResource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: gcUIASP.autoscaleSettings.metrics[0].thresholdToScaleIn
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: gcUIASP.autoscaleSettings.metrics[1].name
              metricNamespace: ''
              metricResourceUri: gcServiceASPResource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: gcUIASP.autoscaleSettings.metrics[1].thresholdToScaleIn
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
    enabled: gcUIASP.autoscaleSettings.autoscaleEnabled
    targetResourceUri: gcServiceASPResource.id
  }
}

resource gcBackendAppsASP01Resource 'Microsoft.Web/serverfarms@2020-06-01' = {
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
  }
}

resource gcBackendAppsASP01_name_setting 'Microsoft.Insights/autoscalesettings@2015-04-01' = {
  name: '${gcBackendAppsASP01.name}-setting'
  location: location
  properties: {
    profiles: [
      {
        name: 'DefaultAutoscaleProfile'
        capacity: {
          minimum: gcBackendAppsASP01.autoscaleSettings.mincapacity
          maximum: gcBackendAppsASP01.autoscaleSettings.maxcapacity
          default: gcBackendAppsASP01.autoscaleSettings.defaultcapacity
        }
        rules: [
          {
            metricTrigger: {
              metricName: gcBackendAppsASP01.autoscaleSettings.metrics[0].name
              metricNamespace: ''
              metricResourceUri: gcBackendAppsASP01Resource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: gcBackendAppsASP01.autoscaleSettings.metrics[0].thresholdToScaleOut
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1M'
            }
          }
          {
            metricTrigger: {
              metricName: gcBackendAppsASP01.autoscaleSettings.metrics[1].name
              metricNamespace: ''
              metricResourceUri: gcBackendAppsASP01Resource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: gcBackendAppsASP01.autoscaleSettings.metrics[1].thresholdToScaleOut
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT1M'
            }
          }
          {
            metricTrigger: {
              metricName: gcBackendAppsASP01.autoscaleSettings.metrics[0].name
              metricNamespace: ''
              metricResourceUri: gcBackendAppsASP01Resource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: gcBackendAppsASP01.autoscaleSettings.metrics[0].thresholdToScaleIn
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: gcBackendAppsASP01.autoscaleSettings.metrics[1].name
              metricNamespace: ''
              metricResourceUri: gcBackendAppsASP01Resource.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: gcBackendAppsASP01.autoscaleSettings.metrics[1].thresholdToScaleIn
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
    enabled: gcBackendAppsASP01.autoscaleSettings.autoscaleEnabled
    targetResourceUri: gcBackendAppsASP01Resource.id
  }
}
