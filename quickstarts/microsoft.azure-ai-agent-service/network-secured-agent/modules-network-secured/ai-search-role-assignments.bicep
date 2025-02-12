/*
AI Search Role Assignments Module
-------------------------------
This module configures RBAC permissions for AI Search service access:

1. Role Assignments:
   - Search Index Data Contributor: Read/write access to search indexes
   - Search Service Contributor: Manage search service settings

2. Unique Assignment Names:
   - Uses deployment-specific suffix for unique role assignments
   - Prevents conflicts in multi-deployment scenarios
*/

@description('Name of the AI Search service')
param aiSearchName string

@description('Principal ID of the managed identity')
param aiProjectPrincipalId string

@description('Unique suffix for resource naming')
param aiProjectId string

// Reference existing search service
resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: aiSearchName
  scope: resourceGroup()
}

/* -------------------------------------------- Role Definitions -------------------------------------------- */

// Search Index Data Contributor Role
// Provides read/write access to search indexes and their data
resource searchIndexDataContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'  // Built-in role ID
  scope: resourceGroup()
}

// Search Service Contributor Role
// Provides access to manage search service settings
resource searchServiceContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'  // Built-in role ID
  scope: resourceGroup()
}

/* -------------------------------------------- Role Assignments -------------------------------------------- */

// Assign Search Index Data Contributor role
// Uses subscription ID and timestamp in guid to ensure uniqueness
resource searchIndexDataContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: searchService
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, searchIndexDataContributorRole.id, aiProjectId)
  properties: {
    principalId: aiProjectPrincipalId
    roleDefinitionId: searchIndexDataContributorRole.id
    principalType: 'ServicePrincipal'
  }
}

// Assign Search Service Contributor role
// Uses subscription ID and timestamp in guid to ensure uniqueness
resource searchServiceContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: searchService
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, searchServiceContributorRole.id, aiProjectId)
  properties: {
    principalId: aiProjectPrincipalId
    roleDefinitionId: searchServiceContributorRole.id
    principalType: 'ServicePrincipal'
  }
}
