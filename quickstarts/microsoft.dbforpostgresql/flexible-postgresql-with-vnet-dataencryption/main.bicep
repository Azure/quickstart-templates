@description('Server Name for Azure database for PostgreSQL Flexible Server')
param serverName string

@description('Name for DNS Private Zone')
param dnsZoneName string 

@description('Fully Qualified DNS Private Zone')
param dnsZoneFqdn string = '${dnsZoneName}.private.postgres.database.azure.com'

@description('Database administrator login name')
@minLength(1)
param administratorLogin string

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for PostgreSQL sku name ')
param skuName string = 'Standard_D2ds_v4'

@description('Azure database for PostgreSQL storage Size ')
param StorageSizeGB int = 32

@description('Azure database for PostgreSQL pricing tier')
@allowed([
  'GeneralPurpose'
  'MemoryOptimized'
  'Burstable'
])
param SkuTier string = 'GeneralPurpose'

@description('PostgreSQL version')
@allowed([
  '11'
  '12'
  '13'
  '14'
])
param postgresqlVersion string = '14'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('PostgreSQL Server backup retention days')
param backupRetentionDays int = 7

@description('Geo-Redundant Backup setting')
param geoRedundantBackup string = 'Disabled'

@description('Virtual Network Name')
param virtualNetworkName string = 'azure_postgresql_vnet'

@description('Subnet Name')
param subnetName string = 'azure_postgresql_subnet'

@description('Virtual Network Address Prefix')
param vnetAddressPrefix string = '10.0.0.0/24'

@description('Subnet Address Prefix')
param postgresqlSubnetPrefix string = '10.0.0.0/28'

@description('Composing the subnetId')
var postgresqlSubnetId =  '${vnetLink.properties.virtualNetwork.id}/subnets/${subnetName}'

@description('Name of the managed identity resource')
param userAssignedIdentityName string = 'azure_postgresql_userassignedidentity_1'

@description('Specifies the name of the key vault.')
param keyVaultName string

@description('Specifies the name of the key in key vault.')
param keyName string

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'get'
  'list'
  'wrapKey'
  'unwrapKey'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'list'
]

@description('String array containing any of: decrypt, encrypt, import, release, sign, unwrapKey, verify, wrapKey')
param keyOps array = [
  'decrypt'
  'encrypt'
  'sign'
  'unwrapKey'
  'verify'
  'wrapKey'
]

@description('High Availability Mode')
@allowed([
  'Disabled'
  'ZoneRedundant'
  'SameZone'
])
param haMode string = 'Disabled'

resource managedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: managedidentity.properties.principalId
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
    ]
    enablePurgeProtection: true
    enableSoftDelete: true
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource kvKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  name: keyName
  parent: kv
  properties: {
    attributes: {
      enabled: true
    }
    keyOps: keyOps
    keySize: 2048
    kty: 'RSA'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }

resource subnet 'subnets@2022-07-01' = {
    name: subnetName
    properties: {
      addressPrefix: postgresqlSubnetPrefix
      delegations: [
        {
          name: 'dlg-Microsoft.DBforPostgreSQL-flexibleServers'
          properties: {
            serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        }
      ]
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
}

resource dnszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneFqdn
  location: 'global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: vnet.name
  parent: dnszone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource postgresqlDbServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: SkuTier
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedidentity.id}': {}
    }
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storage: {
      storageSizeGB: StorageSizeGB
    }
    createMode: 'Default'
    version: postgresqlVersion
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    highAvailability: {
      mode: haMode
    }
    network: {
      delegatedSubnetResourceId: postgresqlSubnetId
      privateDnsZoneArmResourceId: dnszone.id
    }
    dataEncryption: {
      type: 'AzureKeyVault'
      primaryUserAssignedIdentityId: managedidentity.id
      primaryKeyURI: kvKey.properties.keyUriWithVersion
    }
  }
}

output postgreSQLHostname string = '${serverName}.${dnszone.name}'
output postgreSQLSubnetId string = postgresqlSubnetId
output vnetId string = vnet.id
output privateDnsId string = dnszone.id
output privateDnsName string = dnszone.name
