/*
AI Search Service Module
----------------------
This module deploys an Azure AI Search service with network security controls:

1. Security Features:
   - User-assigned managed identity for authentication
   - Public network access disabled
   - AAD-based authentication
   - Optional CMK encryption support

2. Network Security:
   - Private endpoint access only
   - No public internet exposure
   - AAD authentication with bearer challenge

3. Service Configuration:
   - Standard SKU for production workloads
   - Configurable partition and replica counts
   - Managed identity integration

4. Authentication:
   - AAD-first authentication model
   - Bearer token challenge for failed auth
   - Local auth optionally available
*/

/* -------------------------------------------- Parameters -------------------------------------------- */

@description('Name of the user-assigned managed identity')
param userAssignedIdentityName string

@description('Name of the AI Search service')
param aiSearchName string

@description('Azure region for the search service')
param searchLocation string

@description('Tags to add to the resources')
param tags object = {}

/* -------------------------------------------- Resources -------------------------------------------- */

// Reference to user-assigned managed identity
resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: userAssignedIdentityName
  scope: resourceGroup()
}

// AI Search Service
// Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.search/searchservices
resource aiSearch 'Microsoft.Search/searchServices@2024-06-01-preview' = {
  name: aiSearchName
  location: searchLocation
  tags: tags
  identity: {
    type: 'UserAssigned'                            // Use managed identity for authentication
    userAssignedIdentities: {
      '${uai.id}': {}
    }
  }
  properties: {
    disableLocalAuth: false                         // Allow both AAD and API key auth
    authOptions: { 
      aadOrApiKey: { 
        aadAuthFailureMode: 'http401WithBearerChallenge'  // Proper AAD auth challenge
      }
    }
    encryptionWithCmk: {
      enforcement: 'Unspecified'                    // Default encryption mode
    }
    hostingMode: 'default'                          // Standard hosting mode
    partitionCount: 1                               // Number of search partitions
    publicNetworkAccess: 'Disabled'                 // Force private endpoint access
    replicaCount: 1                                 // Number of search replicas
    semanticSearch: 'disabled'                      // Semantic search capability
  }
  sku: {
    name: 'standard'                                // Production-grade SKU
  }
}

/* -------------------------------------------- Outputs -------------------------------------------- */

output searchServiceName string = aiSearch.name
output searchServiceId string = aiSearch.id
output searchServiceEndpoint string = 'https://${aiSearch.name}.search.windows.net'
