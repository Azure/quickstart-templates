/*
Network-Secured AI Hub Module
---------------------------
This module deploys an Azure AI Hub with network-secured configuration:

1. Hub Architecture:
   - Central orchestration point for AI services
   - Manages connections to dependent services
   - Provides network-isolated capability hosting

2. Network Security:
   - VNet integration for capability hosts
   - Private endpoints for service access
   - No public network exposure
   - AAD-based authentication

3. Service Connections:
   - AI Services: For model inference and cognitive capabilities
   - AI Search: For vector storage and search
   - Key Vault: For secure secret management
   - Storage: For data persistence

4. Security Features:
   - User-assigned managed identity
   - RBAC-based access control
   - Private networking for all connections
*/

/* -------------------------------------------- Parameters -------------------------------------------- */

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI hub name')
param aiHubName string

@description('AI hub display name')
param aiHubFriendlyName string = aiHubName

@description('AI hub description')
param aiHubDescription string

@description('Resource ID of the key vault for secure secret storage')
param keyVaultId string

@description('Resource ID of the storage account for data persistence')
param storageAccountId string

// AI Services Configuration
@description('Resource ID of the AI Services')
param aiServicesId string

@description('Endpoint URL of the AI Services')
param aiServicesTarget string

@description('Name of the AI Services resource')
param aiServicesName string

@description('Resource Group containing AI Services')
param aiServiceAccountResourceGroupName string

@description('Subscription ID containing AI Services')
param aiServiceAccountSubscriptionId string

// AI Search Configuration
@description('Name of the AI Search service')
param aiSearchName string

@description('Resource ID of the AI Search service')
param aiSearchId string

@description('Resource Group containing AI Search')
param aiSearchServiceResourceGroupName string

@description('Subscription ID containing AI Search')
param aiSearchServiceSubscriptionId string

@description('Name for capability host that manages AI features')
param capabilityHostName string = 'caphost1'

@description('Name of the user-assigned managed identity')
param uaiName string

@description('Subnet ID for capability host network isolation')
param subnetId string

@description('Flag indicating if the hub already exists')
param aiHubExists bool = false

/* -------------------------------------------- Variables -------------------------------------------- */

// Connection names for service integration
var acsConnectionName = '${aiHubName}-connection-AISearch'
var aoaiConnection = '${aiHubName}-connection-AIServices_aoai'

/* -------------------------------------------- Resources -------------------------------------------- */

// Reference to managed identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: uaiName
}
var userAssignedIdentities = json('{\'${userAssignedIdentity.id}\': {}}')

// Reference to existing services
resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName
  scope: resourceGroup(aiServiceAccountSubscriptionId, aiServiceAccountResourceGroupName)
}

resource searchService 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: aiSearchName
  scope: resourceGroup(aiSearchServiceSubscriptionId, aiSearchServiceResourceGroupName)
}

// AI Hub Workspace
// Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01-preview' = if(!aiHubExists) {
  name: aiHubName
  location: location
  kind: 'hub'
  tags: tags
  identity: {
    type: 'UserAssigned'                            // Use managed identity for authentication
    userAssignedIdentities: userAssignedIdentities
  }
  properties: {
    // Organization metadata
    friendlyName: aiHubFriendlyName
    description: aiHubDescription
    primaryUserAssignedIdentity: userAssignedIdentity.id

    // Core service connections
    keyVault: keyVaultId                           // For secret management
    storageAccount: storageAccountId               // For data persistence
  }

  // AI Services Connection
  // Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces/connections
  resource aiServicesConnection 'connections@2024-07-01-preview' = {
    name: '${aiHubName}-connection-AIServices'
    properties: {
      category: 'AIServices'
      target: aiServicesTarget                     // Service endpoint
      authType: 'AAD'                             // Use Azure AD auth
      isSharedToAll: true                         // Available to all projects
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
        location: aiServices.location
      }
    }
  }

  // AI Search Connection
  resource hub_connection_azureai_search 'connections@2024-07-01-preview' = {
    name: acsConnectionName
    properties: {
      category: 'CognitiveSearch'
      target: 'https://${aiSearchName}.search.windows.net'
      authType: 'AAD'                             // Use Azure AD auth
      isSharedToAll: true                         // Available to all projects
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiSearchId
        location: searchService.location
      }
    }
  }

  // Capability Host Configuration
  // Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces/capabilityhosts
  resource capabilityHost 'capabilityHosts@2024-10-01-preview' = {
    name: capabilityHostName
    properties: {
      customerSubnet: subnetId                    // Network isolation
      capabilityHostKind: 'Agents'               // Enable Agents functionality
    }
  }
  dependsOn: [
    userAssignedIdentity
    aiServices
  ]
}

/* -------------------------------------------- Outputs -------------------------------------------- */

output aiHubID string = aiHub.id
output aoaiConnectionName string = aoaiConnection
output acsConnectionName string = acsConnectionName
