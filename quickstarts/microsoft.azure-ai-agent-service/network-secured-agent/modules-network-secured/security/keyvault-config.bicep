/*
Key Vault Configuration Module
----------------------------
This module deploys a Key Vault with network security controls:

1. Security Features:
   - RBAC authorization
   - Network ACLs
   - Private networking
   - Soft delete enabled

2. Access Controls:
   - Azure AD authentication
   - VNet integration
   - Service endpoint access
*/

@description('Azure region for the deployment')
param location string

@description('Tags to apply to resources')
param tags object = {}

@description('The name of the Key Vault')
param keyvaultName string

@description('Principal ID of the managed identity')
param principalId string

@description('ID of the subnet for network rules')
param subnetId string

@description('Whether to enable public network access')
param enablePublicNetworkAccess bool = false

// Key Vault with network security controls
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyvaultName
  location: location
  tags: tags
  properties: {
    createMode: 'default'
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    enableRbacAuthorization: true
    enablePurgeProtection: true
    publicNetworkAccess: enablePublicNetworkAccess ? 'Enabled' : 'Disabled'
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: principalId
        permissions: { 
          secrets: [ 
            'set'
            'get'
            'list'
            'delete'
            'purge'
          ]
        }
      }
    ]
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: subnetId
        }
      ]
    }
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 7
    tenantId: subscription().tenantId
  }
}

// Diagnostic settings for Key Vault
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${keyvaultName}-diagnostics'
  scope: keyVault
  properties: {
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'AzurePolicyEvaluationDetails'
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
output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
