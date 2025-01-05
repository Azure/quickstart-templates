param location string
param existingVirtualMachineNames array
param sqlServerLicenseType string
param existingVmResourceGroup string
param groupResourceId string

@secure()
param domainAccountPassword string

@secure()
param sqlServicePassword string

resource existingVirtualMachine 'Microsoft.SqlVirtualMachine/SqlVirtualMachines@2022-08-01-preview' = [for item in existingVirtualMachineNames: {
  name: trim(item)
  location: location
  properties: {
    virtualMachineResourceId: resourceId(existingVmResourceGroup, 'Microsoft.Compute/virtualMachines', trim(item))
    sqlServerLicenseType: sqlServerLicenseType
    sqlVirtualMachineGroupResourceId: groupResourceId
    wsfcDomainCredentials: {
      clusterBootstrapAccountPassword: domainAccountPassword
      clusterOperatorAccountPassword: domainAccountPassword
      sqlServiceAccountPassword: sqlServicePassword
    }
  }
}]
