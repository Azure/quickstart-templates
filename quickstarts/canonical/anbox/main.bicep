@description('Add a dedicated disk for the LXD storage pool')
param addDedicatedDataDiskForLXD bool = true

@description('Public SSH key of the virtual machine administrator')
@secure()
param administratorPublicSSHKey string

@description('Virtual machine administrator username')
param administratorUsername string

@description('Expose Anbox container services to the public internet on the port range 10000-11000; when false, Anbox container services will only be accessible from the virtual machine')
param exposeAnboxContainerServices bool = false

@description('Expose the Anbox Management Service to the public internet on port 8444; when false, the Anbox Management Service will only be accessible from the virtual machine')
param exposeAnboxManagementService bool = false

@description('Location of all resources')
param location string = resourceGroup().location

@description('Name of the virtual machine network interface security group')
param networkSecurityGroupName string = 'anboxVirtualMachineNetworkInterfaceSecurityGroup'

@description('CIDR block of the virtual network subnet')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('Name of the virtual network subnet')
param subnetName string = 'anboxVirtualNetworkSubnet'

@description('Offer of the Ubuntu image from which to launch the virtual machine; must be a Pro offer if an argument is not provided for the ubuntuProToken parameter')
param ubuntuImageOffer string = '0001-com-ubuntu-pro-jammy'

@description('SKU of the Ubuntu image from which to launch the virtual machine; must be a Pro SKU if an argument is not provided for the ubuntuProToken parameter')
param ubuntuImageSKU string = 'pro-22_04-lts-arm64'

@description('Ubuntu Pro token to attach to the virtual machine; will be ignored by cloud-init if the arguments provided for the ubuntuImageOffer and ubuntuImageSKU parameters correspond to a Pro image (see https://cloudinit.readthedocs.io/en/latest/reference/modules.html#ubuntu-pro)')
param ubuntuProToken string = ''

@description('Size of the virtual machine data disk (LXD storage pool) when applicable; see the addDedicatedDataDiskForLXD parameter; must comply with https://anbox-cloud.io/docs/reference/requirements#anbox-cloud-appliance-4')
@minValue(100)
@maxValue(1023)
param virtualMachineDataDiskSizeInGB int = 100

@description('Name of the virtual machine')
param virtualMachineName string = 'anboxVirtualMachine'

@description('Size of the virtual machine operating system disk; must comply with https://anbox-cloud.io/docs/reference/requirements#anbox-cloud-appliance-4')
@minValue(40)
@maxValue(1023)
param virtualMachineOperatingSystemDiskSizeInGB int = 40

@description('Size of the virtual machine; must comply with https://anbox-cloud.io/docs/reference/requirements#anbox-cloud-appliance-4')
param virtualMachineSize string = 'Standard_D4ps_v5'

@description('CIDR block of the virtual network')
param virtualNetworkAddressPrefix string = '10.0.0.0/16'

@description('Name of the virtual network')
param virtualNetworkName string = 'anboxVirtualNetwork'

var anboxDestinationPortRangesAnboxManagementService = exposeAnboxManagementService ? ['8444'] : []

var anboxDestinationPortRangesBase = [
  '80'
  '443'
  '5349'
  '60000-60100'
]

var anboxDestinationPortRangesContainers = exposeAnboxContainerServices ? ['10000-11000'] : []

var anboxDestinationPortRanges = concat(anboxDestinationPortRangesAnboxManagementService, anboxDestinationPortRangesBase, anboxDestinationPortRangesContainers)

var cloudConfigWithToken = '''
#cloud-config

package_upgrade: true

ubuntu_advantage:
  token: ubuntuProToken
  enable:
    - anbox-cloud'''

var cloudConfigWithoutToken = '''
#cloud-config

package_upgrade: true

ubuntu_advantage:
  enable:
    - anbox-cloud'''

var cloudConfig = base64(empty(ubuntuProToken) ? cloudConfigWithoutToken : replace(cloudConfigWithToken, 'ubuntuProToken', ubuntuProToken))

var dataDisks = addDedicatedDataDiskForLXD ? [
  {
    createOption: 'Empty'
    diskSizeGB: virtualMachineDataDiskSizeInGB
    lun: 0
    managedDisk: {
      storageAccountType: 'Premium_LRS'
    }
  }
] : []

var imagePlan = empty(ubuntuProToken) && startsWith(ubuntuImageOffer, '0001') ? {
  name: ubuntuImageSKU
  product: ubuntuImageOffer
  publisher: 'canonical'
} : null

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${administratorUsername}/.ssh/authorized_keys'
        keyData: administratorPublicSSHKey
      }
    ]
  }
}

var networkInterfaceName = '${virtualMachineName}NetworkInterface'

var publicIPAddressName = '${virtualMachineName}PublicIP'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'Anbox'
        properties: {
          priority: 1010
          protocol: '*'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRanges: anboxDestinationPortRanges
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${networkInterfaceName}IPConfiguration'
        properties: {
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: virtualMachineName
  location: location
  plan: imagePlan
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: virtualMachineOperatingSystemDiskSizeInGB
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: ubuntuImageOffer
        sku: ubuntuImageSKU
        version: 'latest'
      }
      dataDisks: dataDisks
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: administratorUsername
      adminPassword: administratorPublicSSHKey
      linuxConfiguration: linuxConfiguration
      customData: cloudConfig
    }
  }
}

output sshCommand string = 'ssh -i $PATH_TO_ADMINISTRATOR_PRIVATE_SSH_KEY ${administratorUsername}@${publicIPAddress.properties.ipAddress}'
output virtualMachinePublicIPAddress string = publicIPAddress.properties.ipAddress
