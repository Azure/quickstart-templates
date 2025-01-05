targetScope = 'resourceGroup'

@description('Required. Name of the Virtual Machine.')
param vmName string

@description('Required. Location of the Virtual Machine.')
param location string

@description('Required. Admin username of the Virtual Machine.')
param adminUsername string

@description('Required. Password for the Virtual Machine.')
@secure()
param adminPassword string

@description('Optional. Size of the VM.')
@allowed([
  'Standard_DC2as_v5'
  'Standard_DC2ads_v5'
  'Standard_EC2as_v5'
  'Standard_EC2ads_v5'
  // goes up to 96 core variants
])
param cvmSize string = 'Standard_DC2as_v5'

@description('Optional. OS Image for the Virtual Machine')
@allowed([
  'Windows Server 2022 Gen 2'
  'Windows Server 2019 Gen 2'
])
param osImageName string = 'Windows Server 2022 Gen 2'

@description('Optional. OS disk type of the Virtual Machine.')
@allowed([
  'Premium_LRS'
  'Standard_LRS'
  'StandardSSD_LRS'
])
param osDiskType string = 'Premium_LRS'

@description('Optional. Enable boot diagnostics setting of the Virtual Machine.')
@allowed([
  true
  false
])
param bootDiagnostics bool = false

@description('Optional. Specifies the EncryptionType of the managed disk. It is set to DiskWithVMGuestState for encryption of the managed disk along with VMGuestState blob, and VMGuestStateOnly for encryption of just the VMGuestState blob. NOTE: It can be set for only Confidential VMs.')
@allowed([
  'VMGuestStateOnly' // virtual machine guest state (VMGS) disk
  'DiskWithVMGuestState' // Full disk encryption
])
param securityType string = 'DiskWithVMGuestState'

@description('Custom Attestation Endpoint to attest to. By default, MAA and ASC endpoints are empty and Azure values are populated based on the location of the VM.')
param maaEndpoint string = ''

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@secure()
@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
param _artifactsLocationSasToken string = ''

var virtualNetworkName = '${vmName}-vnet'
var subnetName = '${vmName}-vnet-sn'
var subnetResourceId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'

var maaExtensionName = 'GuestAttestation'
var maaExtensionPublisher = 'Microsoft.Azure.Security.WindowsAttestation'
var maaExtensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var disableAlerts = 'false'
var useAlternateToken = 'false'

var imageList = {
  'Windows Server 2022 Gen 2': {
    publisher: 'microsoftwindowsserver'
    offer: 'windowsserver'
    sku: '2022-datacenter-smalldisk-g2'
    version: 'latest'
  }
  'Windows Server 2019 Gen 2': {
    publisher: 'microsoftwindowsserver'
    offer: 'windowsserver'
    sku: '2019-datacenter-smalldisk-g2'
    version: 'latest'
  }
}

var csExtensionName = 'CustomScriptExtension'
var csExtensionPublisher = 'Microsoft.Compute'
var csExtensionVersion = '1.10'
var setupScriptFileName = 'Install-AccGuestAttestation.ps1'
var setupCommand = 'powershell.exe -ExecutionPolicy Bypass -File .\\assets\\${setupScriptFileName}"'

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${vmName}-ip'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: '${vmName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetResourceId
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}

resource confidentialVm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: bootDiagnostics
      }
    }
    hardwareProfile: {
      vmSize: cvmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
          securityProfile: {
            securityEncryptionType: securityType
          }
        }
      }
      imageReference: imageList[osImageName]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'ConfidentialVM'
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: confidentialVm
  name: maaExtensionName
  location: location
  properties: {
    publisher: maaExtensionPublisher
    type: maaExtensionName
    typeHandlerVersion: maaExtensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
        AscSettings: {
          ascReportingEndpoint: substring(maaEndpoint, 0, 0)
          ascReportingFrequency: substring(maaEndpoint, 0, 0)
        }
        useCustomToken: useAlternateToken
        disableAlerts: disableAlerts
      }
    }
  }
}



resource vmCustomScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: confidentialVm
  name: csExtensionName
  location: location
  properties: {
    publisher: csExtensionPublisher
    type: csExtensionName
    typeHandlerVersion: csExtensionVersion
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: setupCommand
    }
    protectedSettings: {
      fileUris: [
        uri(_artifactsLocation, 'assets/${setupScriptFileName}${_artifactsLocationSasToken}')
      ]
    }
  }
}

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = contains(confidentialVm.identity, 'principalId') ? confidentialVm.identity.principalId : ''
