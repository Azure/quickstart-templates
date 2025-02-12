/*
Storage Role Assignments Module
-----------------------------
This module configures RBAC permissions for Storage Account access:

1. Role Assignments:
   - Storage Blob Data Owner: Full access to blob containers and data
   - Storage Queue Data Contributor: Read/write access to queues

2. Unique Assignment Names:
   - Uses subscription and resource group IDs
   - Includes deployment-specific suffix
   - Prevents conflicts in multi-deployment scenarios
*/

@description('Name of the storage account')
param storageName string

@description('Principal ID of the managed identity')
param UAIPrincipalId string

@description('Unique suffix for resource naming')
param suffix string = ''

// Reference existing storage account
resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageName
  scope: resourceGroup()
}

/* -------------------------------------------- Role Definitions -------------------------------------------- */

// Storage Blob Data Owner Role
// Provides full access to Azure Storage blob containers and data
resource storageBlobDataOwner 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'  // Built-in role ID
  scope: resourceGroup()
}

// Storage Queue Data Contributor Role
// Provides read/write access to Azure Storage queues and messages
resource storageQueueDataContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'  // Built-in role ID
  scope: resourceGroup()
}

/* -------------------------------------------- Role Assignments -------------------------------------------- */

// Assign Storage Blob Data Owner role
resource storageBlobDataOwnerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, storageBlobDataOwner.id, suffix)
  properties: {
    principalId: UAIPrincipalId
    roleDefinitionId: storageBlobDataOwner.id
    principalType: 'ServicePrincipal'
  }
}

// Assign Storage Queue Data Contributor role
resource storageQueueDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, storageQueueDataContributor.id, suffix)
  properties: {
    principalId: UAIPrincipalId
    roleDefinitionId: storageQueueDataContributor.id
    principalType: 'ServicePrincipal'
  }
}
