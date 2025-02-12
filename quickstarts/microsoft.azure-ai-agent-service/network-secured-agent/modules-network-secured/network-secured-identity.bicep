/*
Network-Secured Identity Module
-----------------------------
This module manages the User-Assigned Managed Identity (UAI) for the network-secured deployment:

1. Purpose:
   - Provides a managed identity for secure service-to-service authentication
   - Enables zero-trust security model with no credential storage
   - Used by AI services to access other Azure resources

2. Features:
   - Supports new identity creation or existing identity reference
   - Provides identity properties through outputs
   - Enables RBAC-based access control

3. Security Benefits:
   - No password/secret management required
   - Platform-managed credential rotation
   - Granular access control through RBAC
*/

@description('Azure region for resource deployment')
param location string

@description('Name of the user-assigned managed identity')
param userAssignedIdentityName string

@description('Flag indicating if the identity already exists')
param uaiExists bool = false

/* -------------------------------------------- Identity Resources -------------------------------------------- */

// Reference existing identity if specified
resource existingUAI 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = if(uaiExists) {
  name: userAssignedIdentityName
  scope: resourceGroup()
}

// Create new identity if it doesn't exist
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  location: location
  name: userAssignedIdentityName
}

/* -------------------------------------------- Outputs -------------------------------------------- */

// Identity name for reference by other resources
output uaiName string = uaiExists ? existingUAI.name : userAssignedIdentity.name

// Full resource ID for RBAC assignments
output uaiId string = uaiExists ? existingUAI.id : userAssignedIdentity.id

// Principal ID for role assignments
output uaiPrincipalId string = uaiExists ? existingUAI.properties.principalId : userAssignedIdentity.properties.principalId

// Client ID for service authentication
output uaiClientId string = uaiExists ? existingUAI.properties.clientId : userAssignedIdentity.properties.clientId
