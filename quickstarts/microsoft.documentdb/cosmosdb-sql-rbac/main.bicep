@description('Location for all resources.')
param location string = resourceGroup().location

@description('Cosmos DB account name, max length 44 characters')
param accountName string = toLower('sql-rbac-${uniqueString(resourceGroup().id)}')

@description('Friendly name for the SQL Role Definition')
param roleDefinitionName string = 'My Read Write Role'

@description('Data actions permitted by the Role Definition')
param dataActions array = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
]

@description('Object ID of the AAD identity. Must be a GUID.')
param principalId string

var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]
var roleDefinitionId = guid('sql-role-definition-', principalId, databaseAccount.id)
var roleAssignmentId = guid(roleDefinitionId, principalId, databaseAccount.id)

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: accountName
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
  }
}

resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' = {
  name: '${databaseAccount.name}-${roleDefinitionId}'
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      databaseAccount.id
    ]
    permissions: [
      {
        dataActions: dataActions
      }
    ]
  }
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  name: '${databaseAccount.name}-${roleAssignmentId}'
  properties: {
    roleDefinitionId: sqlRoleDefinition.id
    principalId: principalId
    scope: databaseAccount.id
  }
}
