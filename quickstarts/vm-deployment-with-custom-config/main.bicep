@description('The name of the virtual machine.')
param vmName string = 'myVM'

@description('The admin username for the VM.')
param adminUsername string = 'azureUser'

@secure()
@description('The admin password for the VM.')
param adminPassword string

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
  }
}
