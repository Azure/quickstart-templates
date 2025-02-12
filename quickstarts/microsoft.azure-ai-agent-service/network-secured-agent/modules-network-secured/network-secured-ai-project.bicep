/*
Network-Secured AI Project Module
-------------------------------
This module deploys an Azure AI Project workspace with network-secured configuration:

1. Project Configuration:
   - Creates an AI Project workspace with managed identity
   - Configures capability host for Agents functionality
   - Sets up secure connections to dependent services

2. Security Features:
   - Uses user-assigned managed identity for authentication
   - Integrates with network-secured AI Hub
   - Configures private connections to storage and services

3. Service Connections:
   - Storage: For data persistence
   - AI Search: For vector storage and search capabilities
   - AI Services: For model inference and cognitive capabilities

4. Network Security:
   - All connections use private endpoints
   - No public internet exposure
   - Secure service-to-service communication
*/

/* -------------------------------------------- Parameters -------------------------------------------- */

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI Project name')
param aiProjectName string

@description('AI Project display name')
param aiProjectFriendlyName string = aiProjectName

@description('AI Project description')
param aiProjectDescription string

@description('Resource ID of the AI Hub resource')
param aiHubId string

@description('Name for capability host that manages AI features')
param capabilityHostName string = 'caphost1'

@description('Name for Azure Cognitive Search connection')
param acsConnectionName string

@description('Name for Azure OpenAI connection')
param aoaiConnectionName string

@description('Name of the user-assigned managed identity')
param uaiName string

/* -------------------------------------------- Variables -------------------------------------------- */

// Connection string components
var subscriptionId = subscription().subscriptionId
var resourceGroupName = resourceGroup().name
var projectConnectionString = '${location}.api.azureml.ms;${subscriptionId};${resourceGroupName};${aiProjectName}'

// Service connections
var storageConnections = ['${aiProjectName}/workspaceblobstore']    // Blob storage for workspace data
var aiSearchConnection = ['${acsConnectionName}']                    // Vector storage for embeddings
var aiServiceConnections = ['${aoaiConnectionName}']                 // AI model inference

/* -------------------------------------------- Resources -------------------------------------------- */

// Reference to user-assigned managed identity
resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: uaiName
  scope: resourceGroup()
}

// AI Project Workspace
// Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2023-08-01-preview' = {
  name: aiProjectName
  location: location
  tags: union(tags, {
    ProjectConnectionString: projectConnectionString  // Store connection string in tags for easy access
  })
  identity: {
    type: 'UserAssigned'                            // Use managed identity for authentication
    userAssignedIdentities: {
      '${uai.id}': {}
    }
  }
  properties: {
    // Organization metadata
    friendlyName: aiProjectFriendlyName
    description: aiProjectDescription
    primaryUserAssignedIdentity: uai.id

    // Hub integration
    hubResourceId: aiHubId                          // Link to network-secured AI Hub
  }
  kind: 'project'

  // Capability Host Configuration
  // Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces/capabilityhosts
  resource capabilityHost 'capabilityHosts@2024-10-01-preview' = {
    name: '${aiProjectName}-${capabilityHostName}'
    properties: {
      capabilityHostKind: 'Agents'                  // Enable Agents functionality
      aiServicesConnections: aiServiceConnections   // AI model connections
      vectorStoreConnections: aiSearchConnection    // Vector storage connections
      storageConnections: storageConnections        // Blob storage connections
    }
  }
}

/* -------------------------------------------- Outputs -------------------------------------------- */

// Project identifiers
output aiProjectName string = aiProject.name
output aiProjectResourceId string = aiProject.id
output aiProjectWorkspaceId string = aiProject.properties.workspaceId
output projectConnectionString string = aiProject.tags.ProjectConnectionString
