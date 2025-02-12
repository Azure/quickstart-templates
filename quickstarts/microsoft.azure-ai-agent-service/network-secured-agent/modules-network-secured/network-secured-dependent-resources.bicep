/*
Network-Secured Dependencies Module
---------------------------------
This module deploys core infrastructure components with network security controls:

1. Virtual Network Architecture:
   - Address space: 172.16.0.0/16
   - Customer Hub subnet: 172.16.0.0/24 (for private endpoints)
   - Agents subnet: 172.16.101.0/24 (for container apps)

2. Network Security Features:
   - Service endpoints for secure Azure service access
   - Network ACLs to restrict access
   - Private endpoints for secure communication
   - Disabled public network access

3. Subnet Configuration:
   - Customer Hub subnet: Hosts private endpoints and service endpoints
   - Agents subnet: Delegated to container apps with specific CIDR range
*/

param storageExists bool = false
param keyvaultExists bool = false
param aiServicesExists bool = false
param aiSearchExists bool = false

@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('Tags to add to the resources')
param tags object = {}

@description('Unique suffix for resource names')
param suffix string

@description('AI services name')
param aiServicesName string

@description('The name of the Key Vault')
param keyvaultName string

@description('The name of the AI Search resource')
param aiSearchName string

@description('Name of the storage account')
param storageName string

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

@description('Model/AI Resource deployment location')
param modelLocation string 

@description('The Kind of AI Service, can be "OpenAI" or "AIService"')
param aisKind string

// Network Resource Names
@description('The name of the virtual network')
param vnetName string = 'agents-vnet-${suffix}'

@description('The name of Agents Subnet for container apps')
param agentsSubnetName string = 'agents-subnet-${suffix}'

@description('The name of Customer Hub subnet for private endpoints')
param cxSubnetName string = 'hub-subnet-${suffix}'

param userAssignedIdentityName string

// Subnet reference variables for network rules
var cxSubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, cxSubnetName)
var agentSubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, agentsSubnetName)

// User-assigned managed identity for secure access
resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  location: location
  name: userAssignedIdentityName
}

/* -------------------------------------------- Virtual Network Resources -------------------------------------------- */

// Virtual Network with segregated subnets and security controls
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/16'    // Main VNet CIDR
      ]
    }
    subnets: [
      {
        name: cxSubnetName
        properties: {
          addressPrefix: '172.16.0.0/24'    // Customer Hub subnet CIDR
          serviceEndpoints: [               // Secure service access
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
                modelLocation
              ]
            }
          ]
        }
      }
      {
        name: agentsSubnetName
        properties: {
          addressPrefix: '172.16.101.0/24'  // Agents subnet CIDR
          delegations: [
            {
              name: 'Microsoft.app/environments'
              properties: {
                serviceName: 'Microsoft.app/environments'
              }
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    uai
  ]
}

/* -------------------------------------------- Existing Resource References -------------------------------------------- */

resource existingStorage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if(storageExists) {
  name: storageName
  scope: resourceGroup()
}

resource existingKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = if(keyvaultExists) {
  name: keyvaultName
  scope: resourceGroup()
}

resource existingAiServices 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' existing = if(aiServicesExists) {
  name: aiServicesName
  scope: resourceGroup()
}

resource existingAiSearch 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' existing = if(aiSearchExists) {
  name: aiSearchName
  scope: resourceGroup()
}

/* -------------------------------------------- Network-Secured Resources -------------------------------------------- */

// Key Vault with network security controls
resource defaultKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' = if(!keyvaultExists) {
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
    publicNetworkAccess: 'Disabled'        // Block public access
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: uai.properties.principalId
        permissions: { secrets: [ 'set', 'get', 'list', 'delete', 'purge' ] }
      }
    ]
    networkAcls: {
      bypass: 'AzureServices'              // Allow trusted Azure services
      defaultAction: 'Deny'                // Deny all other traffic
      virtualNetworkRules:[                // Allow access from customer hub subnet
        {
          id: virtualNetwork.properties.subnets[0].id
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

// AI Services with network security controls
resource defaultAiServices 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' = if(!aiServicesExists) {
  name: aiServicesName
  location: modelLocation
  sku: {
    name: 'S0'
  }
  kind: aisKind
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: toLower('${(aiServicesName)}')
    apiProperties: {
      statisticsEnabled: false
    }
    networkAcls: {
      bypass: 'AzureServices'              // Allow trusted Azure services
      defaultAction: 'Deny'                // Deny all other traffic
      virtualNetworkRules:[                // Allow access from customer hub subnet
        {
          id: virtualNetwork.properties.subnets[0].id
        }
      ]
    }
    publicNetworkAccess: 'Disabled'        // Block public access
  }
}

// AI Model deployment
resource defaultModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-06-01-preview'= if(!aiServicesExists){
  parent: defaultAiServices
  name: modelName
  sku : {
    capacity: modelCapacity
    name: modelSkuName
  }
  properties: {
    model:{
      name: modelName
      format: modelFormat
      version: modelVersion
    }
  }
}

// AI Search with network security controls
resource defaultAiSearch 'Microsoft.Search/searchServices@2024-06-01-preview' = if(!aiSearchExists) {
  name: aiSearchName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uai.id}': {}
    }
  }
  properties: {
    disableLocalAuth: false
    authOptions: { aadOrApiKey: { aadAuthFailureMode: 'http401WithBearerChallenge' }}
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    hostingMode: 'default'
    partitionCount: 1
    publicNetworkAccess: 'Disabled'        // Block public access
    replicaCount: 1
    semanticSearch: 'disabled'
  }
  sku: {
    name: 'standard'
  }
}

// Storage Account with network security controls
param noZRSRegions array = ['southindia', 'westus']
param sku object = contains(noZRSRegions, location) ? { name: 'Standard_GRS' } : { name: 'Standard_ZRS' }
var storageNameCleaned = storageExists ? existingStorage.name : replace(storageName, '-', '')

resource defaultStorage 'Microsoft.Storage/storageAccounts@2022-05-01' = if(!storageExists){
  name: storageNameCleaned
  location: location
  kind: 'StorageV2'
  sku: sku
  properties: {
    minimumTlsVersion: 'TLS1_2'           // Enforce TLS 1.2
    allowBlobPublicAccess: false          // Prevent public blob access
    publicNetworkAccess: 'Disabled'        // Block public access
    networkAcls: {
      bypass: 'AzureServices'              // Allow trusted Azure services
      defaultAction: 'Deny'                // Deny all other traffic
      virtualNetworkRules: [               // Allow access from customer hub subnet
        {
          id: cxSubnetRef
        }
      ]
    }
    allowSharedKeyAccess: false           // Enforce Azure AD authentication
  }
  dependsOn: [
    virtualNetwork
  ]
}

/* -------------------------------------------- Role Assignments -------------------------------------------- */

module storageAccessAssignment './storage-role-assignments.bicep' = if(!storageExists){
  name: 'dependencies-${suffix}-storage-rbac'
  params: {
    suffix: suffix
    storageName: storageNameCleaned
    UAIPrincipalId: uai.properties.principalId
    }
  dependsOn: [ defaultStorage ]
}

module keyVaultAccessAssignment './keyvault-role-assignments.bicep' = if(!keyvaultExists){
  name: 'dependencies-${suffix}-keyvault-rbac'
  params: {
    suffix: suffix
    keyvaultName: keyvaultName
    UAIPrincipalId: uai.properties.principalId
    }
  dependsOn: [ defaultKeyVault ]
}

module cognitiveServicesAccessAssignment './cognitive-services-role-assignments.bicep' = if(!aiServicesExists){
  name: 'dependencies-${suffix}-cogsvc-rbac'
  params: {
    suffix: suffix
    UAIPrincipalId: uai.properties.principalId
    }
  dependsOn: [ defaultAiServices ]
}

module aiSearchAccessAssignment 'ai-search-role-assignments.bicep' = if(!aiSearchExists){
  name: 'dependencies-${suffix}-aisearch-rbac'
  params: {
    aiProjectId: aiSearchName
    aiProjectPrincipalId: uai.properties.principalId
    aiSearchName: aiSearchName
    }
  dependsOn: [ defaultAiSearch ]
}

/* -------------------------------------------- Output Variables -------------------------------------------- */

var aiServiceParts = aiServicesExists ? split(existingAiServices.id, '/') : split(defaultAiServices.id, '/')
var acsParts = aiSearchExists ? split(existingAiSearch.id, '/') : split(defaultAiSearch.id, '/')
var storageParts = storageExists ? split(existingStorage.id, '/') : split(defaultStorage.id, '/')

output aiServicesName string =  aiServicesExists ? existingAiServices.name : defaultAiServices.name
output aiservicesID string = aiServicesExists ? existingAiServices.id : defaultAiServices.id
output aiservicesTarget string = aiServicesExists ? existingAiServices.properties.endpoint : defaultAiServices.properties.endpoint
output aiServiceAccountResourceGroupName string = aiServiceParts[4]
output aiServiceAccountSubscriptionId string = aiServiceParts[2] 

output aiSearchName string = aiSearchExists ? existingAiSearch.name : defaultAiSearch.name
output aisearchID string = aiSearchExists ? existingAiSearch.id : defaultAiSearch.id
output aiSearchServiceResourceGroupName string = acsParts[4]
output aiSearchServiceSubscriptionId string = acsParts[2]

output storageAccountName string = storageExists ? existingStorage.name :  storageName
output storageId string =  storageExists ? existingStorage.id : defaultStorage.id
output storageAccountResourceGroupName string = storageParts[4]
output storageAccountSubscriptionId string = storageParts[2]

output virtualNetworkName string = virtualNetwork.name
output virtualNetworkId string = virtualNetwork.id
output cxSubnetName string = cxSubnetName
output agentSubnetName string = agentsSubnetName
output cxSubnetId string = cxSubnetRef
output agentSubnetId string = agentSubnetRef

output keyvaultId string = keyvaultExists ? existingKeyVault.id : defaultKeyVault.id
