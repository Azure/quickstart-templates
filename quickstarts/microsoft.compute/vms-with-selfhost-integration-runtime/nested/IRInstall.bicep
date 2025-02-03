param datafactoryId string
param virtualMachineName string
param existingVnetLocation string
param scriptUrl string

resource installGW 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${virtualMachineName}/${virtualMachineName}installGW'
  location: existingVnetLocation
  tags: {
    vmname: virtualMachineName
  }
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        scriptUrl
      ]
    }
    protectedSettings: {
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File gatewayInstall.ps1 ${listAuthKeys(datafactoryId, '2018-06-01').authKey1}'
    }
  }
}
