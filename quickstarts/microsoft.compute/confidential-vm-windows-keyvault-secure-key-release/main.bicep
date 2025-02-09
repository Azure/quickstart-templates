targetScope = 'resourceGroup'

@description('Required. Specifies the Azure location where the key vault should be created.')
param location string = resourceGroup().location

@description('Required. Name of the Confidential Virtual Machine.')
param cvmName string

@description('Required. Admin username of the Virtual Machine.')
param adminUsername string

@description('Required. Password for the Virtual Machine.')
@secure()
param adminPassword string

@description('Required. Specifies the name of the key vault.')
param keyVaultName string

@description('Optional. Not before date for the Key Vault Key in seconds since 1970-01-01T00:00:00Z.')
param keyNotBefore int = dateTimeToEpoch(utcNow())

@description('Optional. Expiry date the Key Vault Key in seconds since 1970-01-01T00:00:00Z.')
param keyExpiration int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@secure()
@description('The sasToken required to access _artifactsLocation. When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
param _artifactsLocationSasToken string = ''

module cvm 'modules/confidential-virtual-machine.bicep' = {
  name: 'cvm'
  params:{
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
    vmName: cvmName
    osImageName: 'Windows Server 2022 Gen 2'
    cvmSize: 'Standard_DC2as_v5'
    securityType: 'DiskWithVMGuestState'
    bootDiagnostics: false
    osDiskType: 'Standard_LRS'
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
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
    keyExportable: true
    keyEnabled: true
    keyOps: ['encrypt','decrypt']
    keyNotBefore:keyNotBefore
    keyExpiration: keyExpiration
    releasePolicyContentType: 'application/json; charset=utf-8'
    releasePolicyData: loadFileAsBase64('assets/cvm-release-policy.json')
  }
}
