param location string
param prefix string

param apiKey string
param autoGeneratedDomainNameLabelScope string
param deterministicOutboundIP string
param grafanaMajorVersion string
param grafanaSkuName string
param publicNetworkAccess string
param smtp bool
param grafanaIntegrations object
param zoneRedundancy string
param privateDnsZoneName string
param privateLinkServiceUrl string
param virtualNetworkId string
param virtualNetworkName string
param subnetId string
param helmOutput string

param  privateLinkResourceId string = resourceId('Microsoft.Network/privateLinkServices', 'prometheusManagedPls')
//'/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Network/privateLinkServices/prometheusManagedPls'



resource grafana 'Microsoft.Dashboard/grafana@2022-10-01-preview' = {
  name: '${prefix}-grafana'
  location: location
  sku: {
    name: grafanaSkuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    apiKey: apiKey
    autoGeneratedDomainNameLabelScope: autoGeneratedDomainNameLabelScope
    deterministicOutboundIP: deterministicOutboundIP
    grafanaConfigurations: {
      smtp: {
        enabled: smtp
      }
    }
    grafanaIntegrations: grafanaIntegrations
    grafanaMajorVersion: grafanaMajorVersion
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
  }
}

resource grafana1RoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
  scope: subscription()
}

resource grafana1RoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, grafana.id, '1')
  scope: resourceGroup()
  properties: {
    principalId: grafana.identity.principalId
    roleDefinitionId: grafana1RoleDefinition.id//'7f951dda-4ed3-4680-a7ca-43fe172d538d'
  }
}

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  location: 'global'
  name: privateDnsZoneName
  properties: {}
}

resource virtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDNSZone
  location: 'global'
  name: toLower(virtualNetworkName)
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource grafanaPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  location: location
  name: '${grafana.name}-pe'
  properties: {
    customDnsConfigs: []
    customNetworkInterfaceName: ''
    ipConfigurations: []
    manualPrivateLinkServiceConnections: []
    privateLinkServiceConnections: [
      {
        name: '${grafana.name}-pe'
        properties: {
          privateLinkServiceId: grafana.id
          groupIds: [
            split(split(grafana.type, '/')[1], '@')[0]
          ]
          privateLinkServiceConnectionState: {
            actionsRequired: ''
            description: 'Auto-Approved'
            status: 'Approved'
          }
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: grafanaPrivateEndpoint
  name: '${grafana.name}-dnszonegroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: replace(privateDNSZone.name, '.', '-')
        properties: {
          privateDnsZoneId: privateDNSZone.id
        }
      }
    ]
  }
}

resource grafanaManagedEndpoint 'Microsoft.Dashboard/grafana/managedPrivateEndpoints@2022-10-01-preview' = {
  parent: grafana
  location: location
  name: helmOutput
  properties: {
    privateLinkResourceId: privateLinkResourceId
    privateLinkServiceUrl: privateLinkServiceUrl
    requestMessage: 'Please approve my connection'
  }

  dependsOn: [
    grafanaPrivateEndpoint
  ]
}

module privateLinkApproval 'privatelinkapproval.bicep' = {
  name: 'PrivateLinkApprovalScripts'
  params: {
    location: location
    privateLinkServicenName: 'prometheusManagedPls'
    helmOutput: helmOutput
  }

  dependsOn: [
    grafanaManagedEndpoint
  ]
}

output grafaneEndpoint string = grafana.properties.endpoint
output mpeplsEndpoint string = grafanaManagedEndpoint.properties.privateLinkServiceUrl