/*
AI Services Role Assignments Module
--------------------------------
This module configures RBAC permissions for AI Services access:

1. Role Assignments:
   - Cognitive Services Contributor: Full service management
   - Cognitive Services OpenAI User: Access to OpenAI features
   - Cognitive Services User: Basic service usage

2. Unique Assignment Names:
   - Uses subscription and resource group IDs
   - Includes deployment-specific identifiers
   - Prevents conflicts in multi-deployment scenarios
*/

@description('Name of the AI Services account')
param aiServicesName string

@description('Principal ID of the managed identity')
param aiProjectPrincipalId string

@description('Unique identifier for role assignments')
param aiProjectId string

// Reference existing AI Services account
resource aiServices 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' existing = {
  name: aiServicesName
  scope: resourceGroup()
}

/* -------------------------------------------- Role Definitions -------------------------------------------- */

// Cognitive Services Contributor Role
// Provides full access to manage AI services and their settings
resource cognitiveServicesContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'  // Built-in role ID
  scope: resourceGroup()
}

// Cognitive Services OpenAI User Role
// Provides access to use OpenAI features
resource cognitiveServicesOpenAIUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'  // Built-in role ID
  scope: resourceGroup()
}

// Cognitive Services User Role
// Provides basic access to use AI services
resource cognitiveServicesUserRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'  // Built-in role ID
  scope: resourceGroup()
}

/* -------------------------------------------- Role Assignments -------------------------------------------- */

// Assign Cognitive Services Contributor role
resource cognitiveServicesContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01'= {
  scope: aiServices
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, cognitiveServicesContributorRole.id, aiProjectId)
  properties: {  
    principalId: aiProjectPrincipalId
    roleDefinitionId: cognitiveServicesContributorRole.id
    principalType: 'ServicePrincipal'
  }
}

// Assign Cognitive Services OpenAI User role
resource cognitiveServicesOpenAIUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aiServices
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, cognitiveServicesOpenAIUserRole.id, aiProjectId)
  properties: {
    principalId: aiProjectPrincipalId
    roleDefinitionId: cognitiveServicesOpenAIUserRole.id
    principalType: 'ServicePrincipal'
  }
}

// Assign Cognitive Services User role
resource cognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aiServices
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, cognitiveServicesUserRole.id, aiProjectId)
  properties: {
    principalId: aiProjectPrincipalId
    roleDefinitionId: cognitiveServicesUserRole.id
    principalType: 'ServicePrincipal'
  }
}
