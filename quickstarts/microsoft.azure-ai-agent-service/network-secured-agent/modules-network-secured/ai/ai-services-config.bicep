/*
AI Services Configuration Module
-----------------------------
This module deploys AI Services with network security controls:

1. Security Features:
   - Network ACLs
   - Private networking
   - Managed identity
   - Custom subdomain

2. Model Deployment:
   - Model configuration
   - SKU settings
   - Capacity management
*/

@description('Azure region for the deployment')
param location string

@description('Tags to apply to resources')
param tags object = {}

@description('The name of the AI Services account')
param aiServicesName string

@description('ID of the subnet for network rules')
param subnetId string

@description('Whether to enable public network access')
param enablePublicNetworkAccess bool = false

// Model deployment parameters
@description('Model name for deployment')
param modelName string

@description('Model format for deployment')
param modelFormat string

@description('Model version for deployment')
param modelVersion string

@description('Model deployment SKU name')
param modelSkuName string

@description('Model deployment capacity')
param modelCapacity int

@description('Log Analytics workspace ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

// AI Services account with network security controls
resource aiServices 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' = {
  name: aiServicesName
  location: location
  tags: tags
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: toLower(aiServicesName)
    apiProperties: {
      statisticsEnabled: false
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: subnetId
        }
      ]
    }
    publicNetworkAccess: enablePublicNetworkAccess ? 'Enabled' : 'Disabled'
  }
}

// Model deployment
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-06-01-preview' = {
  parent: aiServices
  name: modelName
  sku: {
    capacity: modelCapacity
    name: modelSkuName
  }
  properties: {
    model: {
      name: modelName
      format: modelFormat
      version: modelVersion
    }
  }
}

// Diagnostic settings
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${aiServicesName}-diagnostics'
  scope: aiServices
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'Audit'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'RequestResponse'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Output variables
output aiServicesName string = aiServices.name
output aiServicesId string = aiServices.id
output aiServicesEndpoint string = aiServices.properties.endpoint
output modelDeploymentName string = modelDeployment.name
output principalId string = aiServices.identity.principalId
