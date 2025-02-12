/*
Key Vault Role Assignments Module
------------------------------
This module configures RBAC permissions for Azure Key Vault:

1. Role Configuration:
   - Key Vault Contributor (f25e0fa2-a7c8-4377-a976-54943a77a395)
     * Manage Key Vault resources
     * Cannot access secret content
   - Key Vault Secrets Officer (b86a8fe4-44ce-4948-aee5-eccb2c155cd7)
     * Full access to secrets
     * Manage secret metadata

2. Permissions Granted:
   Key Vault Contributor:
   - Manage vault properties
   - Create/delete vaults
   - Set access policies
   
   Key Vault Secrets Officer:
   - Create/delete secrets
   - Set secret values
   - Configure secret attributes

3. Security Considerations:
   - Uses managed identity for authentication
   - Follows principle of least privilege
   - Separate roles for management vs content access
   - Scoped to specific Key Vault instance
*/

/* -------------------------------------------- Parameters -------------------------------------------- */

@description('Name of the Key Vault')
param keyvaultName string

@description('Principal ID of the managed identity')
param UAIPrincipalId string

@description('Unique suffix for role assignment naming')
param suffix string

/* -------------------------------------------- Resources -------------------------------------------- */

// Reference to existing Key Vault
resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvaultName
  scope: resourceGroup()
}

/* -------------------------------------------- Role Definitions -------------------------------------------- */

// Key Vault Secrets Officer Role
// Provides full access to manage secrets
resource keyVaultSecretOfficer 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'  // Built-in role ID
  scope: keyvault
}

// Key Vault Contributor Role
// Provides access to manage vault but not secrets
resource keyVaultContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'f25e0fa2-a7c8-4377-a976-54943a77a395'  // Built-in role ID
  scope: resourceGroup()
}

/* -------------------------------------------- Role Assignments -------------------------------------------- */

// Assign Key Vault Contributor role
resource keyVaultContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, keyVaultContributor.id, suffix)
  properties: {
    principalId: UAIPrincipalId              // Managed identity principal ID
    roleDefinitionId: keyVaultContributor.id // Contributor role
    principalType: 'ServicePrincipal'        // Identity type
  }
}

// Assign Key Vault Secrets Officer role
resource keyVaultSecretOfficerAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, keyVaultSecretOfficer.id, suffix)
  properties: {
    principalId: UAIPrincipalId                // Managed identity principal ID
    roleDefinitionId: keyVaultSecretOfficer.id // Secrets Officer role
    principalType: 'ServicePrincipal'          // Identity type
  }
}

/* -------------------------------------------- Outputs -------------------------------------------- */

output contributorRoleId string = keyVaultContributorAssignment.id
output secretsOfficerRoleId string = keyVaultSecretOfficerAssignment.id
