@description('Admin username')
param adminUsername string = 'azureuser'

@description('SSH rsa public key file as a string.')
param sshKeyData string

@description('DNS Label for the load balancer Public IP. Must be lowercase. It should match with the regex: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.')
param lbDNSLabelPrefix string

@description('Prefix to use for names of VMs under the load balancer')
param haproxyVmNamePrefix string = 'haproxyvm-'

@description('Prefix to use for names of application VMs')
param appVmNamePrefix string = 'appvm-'

@description('The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version. Allowed values: 12.04.5-LTS, 14.04.5-LTS, 15.10.')
@allowed([
  '12.04.5-LTS'
  '14.04.5-LTS'
  '15.10'
])
param ubuntuOSVersion string = '14.04.5-LTS'

@description('Size of the VM')
param vmSize string = 'Standard_D2_v3'

@description('location')
param location string = resourceGroup().location

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

var storageAccountName = '${uniqueString(resourceGroup().id)}haproxysa'
var numberOfHAproxyInstances = 2
var haproxyVmScripts = {
  fileUris: [
    uri(_artifactsLocation, '/scripts/haproxyvm-configure.sh${_artifactsLocationSasToken}')
    uri(_artifactsLocation, '/scripts/keepalived-action.sh${_artifactsLocationSasToken}')
    uri(_artifactsLocation, '/keepalived-check-appsvc.sh${_artifactsLocationSasToken}')
  ]
  commandToExecute: 'sudo bash -x haproxyvm-configure.sh  -a ${appVmNamePrefix}0 -a ${appVmNamePrefix}1 -p ${appVmPort} -l ${lbDNSLabelPrefix}.${location}.cloudapp.azure.com -t ${lbVIPPort} -m ${haproxyVmNamePrefix}0 -b ${haproxyVmNamePrefix}1'
}
var numberOfAppInstances = 2
var appVmScripts = {
  fileUris: [
    uri(_artifactsLocation, '/scripts/apache-setup.sh${_artifactsLocationSasToken}')
  ]
  commandToExecute: 'sudo bash apache-setup.sh'
}
var appVmPort = 80
var imagePublisher = 'Canonical'
var imageOffer = 'UbuntuServer'
var sshKeyPath = '/home/${adminUsername}/.ssh/authorized_keys'
var nicNamePrefix = 'nic-'
var storageAccountType = 'Standard_LRS'
var haproxyAvailabilitySetName = 'haproxyAvSet'
var appAvailabilitySetName = 'appAvSet'
var vnetName = 'haproxyVNet'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet-1'
var subnetPrefix = '10.0.0.0/24'
var lbName = 'haproxyLB'
var lbPublicIPAddressType = 'Static'
var lbPublicIPAddressName = '${lbName}-publicip'
var lbVIPPort = 80

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
}

resource haproxyAvailabilitySet 'Microsoft.Compute/availabilitySets@2023-03-01' = {
  name: haproxyAvailabilitySetName
  location: location
  properties: {
    platformUpdateDomainCount: 3
    platformFaultDomainCount: 2
  }
  sku: {
    name: 'Aligned'
  }
}

resource appAvailabilitySet 'Microsoft.Compute/availabilitySets@2023-03-01' = {
  name: appAvailabilitySetName
  location: location
  properties: {
    platformUpdateDomainCount: 3
    platformFaultDomainCount: 2
  }
  sku: {
    name: 'Aligned'
  }
}

resource lbPublicIPAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: lbPublicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: lbPublicIPAddressType
    dnsSettings: {
      domainNameLabel: lbDNSLabelPrefix
    }
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
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
        }
      }
    ]
  }
}

resource lb 'Microsoft.Network/loadBalancers@2023-04-01' = {
  name: lbName
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: lbPublicIPAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool1'
      }
    ]
    inboundNatRules: [
      {
        name: 'SSH-VM0'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerFrontEnd')
          }
          protocol: 'Tcp'
          frontendPort: 50001
          backendPort: 22
          enableFloatingIP: false
        }
      }
      {
        name: 'SSH-VM1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerFrontEnd')
          }
          protocol: 'Tcp'
          frontendPort: 50002
          backendPort: 22
          enableFloatingIP: false
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'LBRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerFrontEnd')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'BackendPool1')
          }
          protocol: 'Tcp'
          frontendPort: lbVIPPort
          backendPort: lbVIPPort
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes','lbName', 'tcpProbe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'tcpProbe'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource haproxyVmNic 'Microsoft.Network/networkInterfaces@2023-04-01' = [for i in range(0, numberOfHAproxyInstances): {
  name: '${haproxyVmNamePrefix}${nicNamePrefix}${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          loadBalancerBackendAddressPools: [
            {
              id: lb.properties.backendAddressPools[0].id
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: lb.properties.inboundNatRules[i].id
            }
          ]
        }
      }
    ]
  }
}]

resource haproxyVm 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, numberOfHAproxyInstances): {
  name: '${haproxyVmNamePrefix}${i}'
  location: location
  properties: {
    availabilitySet: {
      id: haproxyAvailabilitySet.id
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${haproxyVmNamePrefix}${i}'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: sshKeyPath
              keyData: sshKeyData
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: ubuntuOSVersion
        version: 'latest'
      }
      osDisk: {
        name: '${haproxyVmNamePrefix}OSDisk-${i}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: haproxyVmNic[i].id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    haproxyVmNic
  ]
}]

resource appVmNic 'Microsoft.Network/networkInterfaces@2023-04-01' = [for i in range(0, numberOfAppInstances): {
  name: '${appVmNamePrefix}${nicNamePrefix}${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}]

resource appVm 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, numberOfAppInstances): {
  name: '${appVmNamePrefix}${i}'
  location: location
  properties: {
    availabilitySet: {
      id: appAvailabilitySet.id
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: '${appVmNamePrefix}${i}'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: sshKeyPath
              keyData: sshKeyData
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: ubuntuOSVersion
        version: 'latest'
      }
      osDisk: {
        name: '${appVmNamePrefix}OSDisk-${i}'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: appVmNic[i].id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
    appVmNic
  ]
}]

resource appVmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, numberOfAppInstances): {
  name: '${appVmNamePrefix}${i}/configureappvm'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: appVmScripts.fileUris
    }
    protectedSettings: {
      commandToExecute: appVmScripts.commandToExecute
    }
  }
  dependsOn: [
    appVm
  ]
}]

resource haproxyVmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, numberOfHAproxyInstances): {
  name: '${haproxyVmNamePrefix}${i}/configureHAproxyVM'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: haproxyVmScripts.fileUris
    }
    protectedSettings: {
      commandToExecute: haproxyVmScripts.commandToExecute
    }
  }
  dependsOn: [
    haproxyVm
    appVmExtension
  ]
}]
