targetScope = 'resourceGroup'

@description('Required. Specifies the name of the key vault.')
param keyVaultName string

@description('Required. Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

@description('Optional Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Required. Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string

@description('Optional. Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'release'
]

@description('Optional. Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'premium'
])
param skuName string = 'premium'

@description('Specifies the name of the Key Vault Key that you want to create.')
param keyName string

@description('The type of the Key Vault Key. Must be backed by HSM, for secure key release. For valid values, see JsonWebKeyType.')
@allowed([
  'EC-HSM'
  'RSA-HSM'
])
param keyType string

@description('Specifies whether the key should be exportable, "true" is required for secure key release.')
param keyExportable bool = true

@description('Optional. Not before date for the Key Vault Key in seconds since 1970-01-01T00:00:00Z.')
param keyNotBefore int = -1

@description('Optional. Determines whether or not the Key Vault Key is enabled, "true" is required for secure key release.')
param keyEnabled bool = true

@description('Optional. Expiry date for the Key Vault Key in seconds since 1970-01-01T00:00:00Z.')
param keyExpiration int = -1

@description('Optional. Key Vault Key elliptic curve name. For valid values, see JsonWebKeyCurveName.')
@allowed([
  'P-256'
  'P-256K'
  'P-384'
  'P-521'
])
param curveName string = 'P-256'

@description('Optional. The Key Vault Key size in bits. For example: 2048, 3072, or 4096 for RSA.')
param keySize int = -1

@description('Optional. Specifies the Key Vault Key operations that can be perform on the specific key. String array containing any of: "decrypt", "encrypt", "import", "release", "sign", "unwrapKey", "verify", "wrapKey"')
@allowed([
  'decrypt'
  'encrypt'
  'import'
  'sign'
  'unwrapKey'
  'verify'
  'wrapKey'
])
param keyOps array = []

@description('Optional. Content type and version of Key Vault Key release policy.')
param releasePolicyContentType string = 'application/json; charset=utf-8'

@description('Required. Blob encoding the policy rules under which the Key Vault Key can be released. Blob must be base64 encoded.')
param releasePolicyData string

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
        }
      }
    ]
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
  parent: kv
  name: keyName
  properties: {
    kty: keyType
    attributes: {
      exportable: keyExportable
      enabled: keyEnabled
      nbf: keyNotBefore == -1 ? null : keyNotBefore
      exp: keyExpiration == -1 ? null : keyExpiration
    }
    curveName: curveName
    keySize: keySize == -1 ? null : keySize
    keyOps: keyOps
    release_policy: {
      contentType: releasePolicyContentType
      data: releasePolicyData
    }
  }
}
