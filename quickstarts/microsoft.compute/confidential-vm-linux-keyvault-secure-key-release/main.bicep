targetScope = 'resourceGroup'

@description('Required. Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

@description('Required. Name of the Confidential Virtual Machine.')
param cvmName string

@description('Required. Admin username of the Virtual Machine.')
param adminUsername string

@description('Required. Password or ssh key for the Virtual Machine.')
@secure()
param adminPasswordOrKey string

@description('Optional. Type of authentication to use on the Virtual Machine.')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

@description('Required. Specifies the name of the key vault.')
param keyVaultName string

@description('Optional. Not before date for the Key Vault Key in seconds since 1970-01-01T00:00:00Z.')
param keyNotBefore int = dateTimeToEpoch(utcNow())

@description('Optional. Expiry date the Key Vault Key in seconds since 1970-01-01T00:00:00Z.')
param keyExpiration int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

module cvm 'modules/confidential-virtual-machine.bicep' = {
  name: 'cvm'
  params:{
    adminUsername: adminUsername
    adminPasswordOrKey: adminPasswordOrKey
    authenticationType: authenticationType
    location: location
    vmName: cvmName
    osImageName: 'Ubuntu 20.04 LTS Gen 2'
    cvmSize: 'Standard_DC2as_v5'
    securityType: 'DiskWithVMGuestState'
    bootDiagnostics: false
    osDiskType: 'Standard_LRS'
    customData: loadFileAsBase64('assets/cloud-config.yml')
  }
}

module akv 'modules/key-vault.bicep' = {
  name: 'akv'
  params:{
    keyVaultName: keyVaultName
    location: location

    objectId: cvm.outputs.systemAssignedPrincipalId
    keysPermissions: [
      'release'
    ]

    keyName: 'myskrkey'
    keyType: 'RSA-HSM'
    keySize: 4096
    keyExportable: true // Required for key release
    keyEnabled: true
    keyOps: ['encrypt','decrypt']
    keyNotBefore:keyNotBefore
    keyExpiration: keyExpiration
    releasePolicyContentType: 'application/json; charset=utf-8'
    releasePolicyData: loadFileAsBase64('assets/cvm-release-policy.json')
  }
}
