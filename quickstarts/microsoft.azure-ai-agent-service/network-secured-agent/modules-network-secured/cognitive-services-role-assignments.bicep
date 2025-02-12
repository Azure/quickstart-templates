/*
Cognitive Services Role Assignments Module
---------------------------------------
This module configures RBAC permissions for Azure AI Services:

1. Role Configuration:
   - Azure AI Administrator Role (b78c5d69-af96-48a3-bf8d-a8b4d589de94)
   - Provides full access to manage AI resources and deployments
   - Required for AI Studio operations

2. Permissions Granted:
   - Create and manage AI deployments
   - Configure model settings
   - Monitor resource usage
   - Manage security settings

3. Security Considerations:
   - Uses managed identity for authentication
   - Scoped to resource group level
   - Follows principle of least privilege

Documentation:
- Azure AI Administrator Role: https://learn.microsoft.com/en-us/azure/ai-studio/concepts/rbac-ai-studio#azure-ai-administrator-role
*/

@description('Principal ID of the managed identity')
param UAIPrincipalId string

@description('Unique suffix for role assignment naming')
param suffix string

/* -------------------------------------------- Role Definitions -------------------------------------------- */

// Azure AI Administrator Role
// Provides full access to manage AI resources and their settings
resource openAIAdmin 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b78c5d69-af96-48a3-bf8d-a8b4d589de94'  // Built-in role ID
  scope: resourceGroup()
}

/* -------------------------------------------- Role Assignments -------------------------------------------- */

// Assign Azure AI Administrator role
resource openAIContributorContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  // Use subscription ID and resource group ID to ensure uniqueness across deployments
  name: guid(subscription().subscriptionId, resourceGroup().id, openAIAdmin.id, suffix)
  properties: {
    principalId: UAIPrincipalId              // Managed identity principal ID
    roleDefinitionId: openAIAdmin.id         // AI Administrator role
    principalType: 'ServicePrincipal'        // Identity type
  }
}

/* -------------------------------------------- Outputs -------------------------------------------- */

output roleAssignmentId string = openAIContributorContributorAssignment.id
