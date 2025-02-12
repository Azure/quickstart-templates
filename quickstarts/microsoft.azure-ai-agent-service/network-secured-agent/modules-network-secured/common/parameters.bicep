/*
Common Parameters Module
----------------------
This module defines common parameters and variables used across the infrastructure:

1. Naming Standards:
   - Resource prefixes
   - Naming patterns
   - Unique suffix generation

2. Network Configuration:
   - Address spaces
   - Subnet ranges
   - Service endpoints

3. Tags:
   - Environment tags
   - Project tags
   - Security tags
*/

// Resource naming
@description('Prefix for resource names')
param prefix string

@description('Azure region for the deployment')
param location string = resourceGroup().location

@description('Environment (e.g., prod, dev, test)')
@allowed([
  'prod'
  'dev'
  'test'
  'stage'
])
param environment string = 'prod'

// Generate unique suffix
var uniqueSuffix = uniqueString(subscription().id, resourceGroup().id, prefix)

// Common tags
var commonTags = {
  Environment: environment
  Project: 'NetworkSecuredAgent'
  SecurityLevel: 'High'
  DataClassification: 'Confidential'
  CostCenter: 'AI-Services'
  CreatedBy: 'IaC'
  ManagedBy: 'DevOps'
}

// Network configuration
var networkConfig = {
  vnetAddressSpace: '172.16.0.0/16'
  hubSubnetPrefix: '172.16.0.0/24'
  agentsSubnetPrefix: '172.16.101.0/24'
  serviceEndpoints: [
    {
      service: 'Microsoft.KeyVault'
      locations: [
        location
      ]
    }
    {
      service: 'Microsoft.Storage'
      locations: [
        location
      ]
    }
    {
      service: 'Microsoft.CognitiveServices'
      locations: [
        location
      ]
    }
  ]
  dnsZones: {
    keyVault: 'privatelink.vaultcore.azure.net'
    storage: 'privatelink.blob.core.windows.net'
    aiServices: 'privatelink.cognitiveservices.azure.com'
    aiSearch: 'privatelink.search.windows.net'
  }
}

// Resource naming patterns
var namingPatterns = {
  vnet: '${prefix}-vnet-${uniqueSuffix}'
  keyvault: 'kv-${prefix}-${uniqueSuffix}'
  storage: '${prefix}store${uniqueSuffix}'
  aiServices: '${prefix}-ai-${uniqueSuffix}'
  aiSearch: '${prefix}-search-${uniqueSuffix}'
  identity: '${prefix}-identity-${uniqueSuffix}'
  logAnalytics: '${prefix}-logs-${uniqueSuffix}'
  privateEndpoint: '${prefix}-pe-${uniqueSuffix}'
}

// Security configuration
var securityConfig = {
  enablePublicAccess: false
  tlsVersion: 'TLS1_2'
  allowSharedKeyAccess: false
  enableSoftDelete: true
  softDeleteRetentionDays: 7
  enablePurgeProtection: true
  diagnosticRetentionDays: 30
  networkAcls: {
    bypass: 'AzureServices'
    defaultAction: 'Deny'
  }
}

// Monitoring configuration
var monitoringConfig = {
  metrics: {
    enabled: true
    retentionDays: 30
  }
  logs: {
    enabled: true
    retentionDays: 30
    categories: {
      audit: true
      requests: true
      operations: true
    }
  }
}

// SKU configuration
var skuConfig = {
  aiServices: {
    name: 'S0'
    tier: 'Standard'
  }
  aiSearch: {
    name: 'standard'
    tier: 'Standard'
  }
  keyVault: {
    name: 'standard'
    family: 'A'
  }
  storage: {
    name: 'Standard_ZRS'
    tier: 'Standard'
  }
}

// Output variables
output suffix string = uniqueSuffix
output tags object = commonTags
output naming object = namingPatterns
output network object = networkConfig
output security object = securityConfig
output monitoring object = monitoringConfig
output skus object = skuConfig
