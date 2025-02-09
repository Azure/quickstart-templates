targetScope = 'resourceGroup'

@description('Required. Name of the Virtual Machine.')
param vmName string

@description('Required. Location of the Virtual Machine.')
param location string

@description('Required. Admin username of the Virtual Machine.')
param adminUsername string

@description('Required. Password or ssh key for the Virtual Machine.')
@secure()
param adminPasswordOrKey string

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
  'Ubuntu 20.04 LTS Gen 2'
  'Ubuntu 22.04 LTS Gen 2'
])
param osImageName string = 'Ubuntu 20.04 LTS Gen 2'

@description('Optional. OS disk type of the Virtual Machine.')
@allowed([
  'Premium_LRS'
  'Standard_LRS'
  'StandardSSD_LRS'
])
param osDiskType string = 'Premium_LRS'

@description('Optional. Type of authentication to use on the Virtual Machine.')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

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

@description('Specifies a base-64 encoded string of custom data. The base-64 encoded string is decoded to a binary array that is saved as a file on the Virtual Machine. The maximum length of the binary array is 65535 bytes. Note: Do not pass any secrets or passwords in customData property This property cannot be updated after the VM is created. customData is passed to the VM to be saved as a file.')
param customData string

var virtualNetworkName = '${vmName}-vnet'
var subnetName = '${vmName}-vnet-sn'
var subnetResourceId = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var addressPrefix = '10.0.0.0/16'
var subnetPrefix = '10.0.0.0/24'

var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.LinuxAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var disableAlerts = 'false'
var useAlternateToken = 'false'

var imageList = {
  'Ubuntu 20.04 LTS Gen 2': {
    publisher: 'canonical'
    offer: '0001-com-ubuntu-confidential-vm-focal' // 👈 Specific confidential VM image offer!
    sku: '20_04-lts-cvm' // 👈 Specific confidential VM image SKU!
    version: 'latest'
  }
}

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
        name:  'SSH'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01'= {
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
      adminPassword: adminPasswordOrKey
      customData: customData
      linuxConfiguration: ((authenticationType == 'password') ? null : {
        disablePasswordAuthentication: 'true'
        ssh: {
          publicKeys: [
            {
              keyData: adminPasswordOrKey
              path: '/home/${adminUsername}/.ssh/authorized_keys'
            }
          ]
        }
      })
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
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
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

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = contains(confidentialVm.identity, 'principalId') ? confidentialVm.identity.principalId : ''
