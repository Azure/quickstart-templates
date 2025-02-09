@description('Username for the virtual Machine(s) hosting the PubSub+ event broker instance(s). Do not use special characters.')
param vmAdminUsername string

@description('Password for the virtual Machine(s). Azure sets rules on passwords, check the online feedback.')
@secure()
param vmAdminPassword string

@description('Password for the PubSub+ event broker management \'admin\' user. For password rules refer to https://docs.solace.com/Configuring-and-Managing/Configuring-Internal-CLI-User-Accounts.htm#Changing-CLI-User-Passwords ')
@secure()
param solaceAdminPassword string

@description('Security group defined to support PubSub+ event broker system level and default message vpn ports.')
param securityGroupName string = 'solace-security'

@description('Optional: Unique OMS Workspace Name for Log Analytics. Leave this field empty to not deploy an OMS Workspace.')
param workspaceName string = ''

@description('OMS Workspace Region for Log Analytics. Not used if Workspace Name is empty.')
@allowed([
  'East US'
  'West Europe'
  'Southeast Asia'
  'Australia Southeast'
  'Japan East'
  'UK South'
  'Central India'
  'Canada Central'
])
param workspaceRegion string = 'East US'

@description('Specify the type of access to the broker VMs for SSH and to the Load Balancer for broker services. \'Internal\' will make them accessible only from the local virtual network')
@allowed([
  'Internal'
  'Public'
])
param vmAndLoadbalancerExposure string = 'Public'

@description('Ignored if Local exposure selected. If using a Public access, provide a unique DNS Label for the Load Balancer access IP. Name must satisfy regular expression ^[a-z][a-z0-9-]{1,61}[a-z0-9]$. Default will generate a unique string')
param dnsLabelForPublicLoadBalancer string = 'lb${uniqueString(resourceGroup().id, deployment().name)}'

@description('Ignored if Local exposure selected. If using a Public access, provide a unique DNS Label for the broker Virtual Machine(s). Do not use \'-\'. Default will generate a unique string')
param dnsLabelForVmIp string = 'vm${uniqueString(resourceGroup().id, deployment().name)}'

@description('The CentOS version for deploying the Docker containers. This will pick a fully patched image of this given CentOS version. Allowed values: 7.9')
@allowed([
  '7_9'
])
param centosVersion string = '7_9'

@description('Broker system scaling: the maximum supported number of client connections')
@allowed([
  '100'
  '1000'
  '10000'
  '100000'
  '200000'
])
param maxNumberOfClientConnections string = '100'

@description('Broker system scaling: the maximum number of queue messages, in millions of messages')
@allowed([
  '100'
  '240'
  '3000'
])
param maxNumberOfQueueMessages string = '100'

@description('The size of a PubSub+ broker message routing node VM. Important: ensure adequate CPU and Memory resources are available to support the selected broker system scaling parameters. For requirements check the resource calculator at https://docs.solace.com/Assistance-Tools/Resource-Calculator/pubsubplus-resource-calculator.html.')
@allowed([
  'Standard_D2_v3'
  'Standard_D4_v3'
  'Standard_D8_v3'
  'Standard_D16_v3'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
  'Standard_D16s_v3'
])
param messageRoutingNodeVmSize string = 'Standard_D2_v3'

@description('The size of the PubSub+ monitor node VM in a High Availabity deployment. For requirements check the resource calculator at https://docs.solace.com/Assistance-Tools/Resource-Calculator/pubsubplus-resource-calculator.html.')
@allowed([
  'Standard_D2_v3'
  'Standard_D2s_v3'
])
param monitorNodeVmSize string = 'Standard_D2_v3'

@description('The size of the data disk in GB for diagnostics and message spooling on the Solace Message Routing Nodes. For requirements check the resource calculator at https://docs.solace.com/Assistance-Tools/Resource-Calculator/pubsubplus-resource-calculator.html.')
@allowed([
  '0'
  '8'
  '16'
  '32'
  '64'
  '128'
  '256'
])
param dataDiskSize string = '0'

@description('Solace PubSub+ event broker docker image reference: a docker registry name with optional tag or a download URL. The download URL can be obtained from http://dev.solace.com/downloads/ or it can be a url to a remotely hosted load version. Default will use the latest image available from Docker Hub.')
param brokerDockerImageReference string = 'solace/solace-pubsub-standard:latest'

@description('Deploy three node HA cluster or single node')
@allowed([
  'HighAvailability'
  'SingleNode'
])
param deploymentModel string

@description('Optional: Only used if deploying into an existing virtual network and subnet. Specify the Existing Virtual Network Name together with the Existing Subnet Name, otherwise leave it at default blank.')
param existingVirtualNetworkName string = ''

@description('Optional: Only used if deploying into an existing virtual network and subnet. Specify the Existing Virtual Network Name together with the Existing Subnet Name, otherwise leave it at default blank.')
param existingSubnetName string = ''

@description('The virtual network\'s address range in CIDR notation where the PubSub+ event broker will be deployed.')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('The subnet\'s address range in CIDR notation where the PubSub+ event broker will be deployed. It must be contained by the address space of the virtual network. The address range of a subnet which is in use can\'t be edited.')
param subnetPrefix string = '10.0.0.0/24'

@description('Location for all resources. Default will use the same location as the Resource Group.')
param location string = resourceGroup().location

@description('The number of fault domains to be used for the deployment. For the maximum number fault domains available to your location refer to https://github.com/MicrosoftDocs/azure-docs/blob/master/includes/managed-disks-common-fault-domain-region-list.md')
param numberOfFaultDomains int = 3

@description('The base URI where artifacts required by this template are located.')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('Optional: The Shared Access Signatures (SAS) token if required for the artifacts location, otherwise leave it at default blank.')
@secure()
param _artifactsLocationSasToken string = ''

var availabilitySetName = 'solaceAvailabilitySet'
var platformFaultDomainCount = numberOfFaultDomains
var platformUpdateDomainCount = ((numberOfFaultDomains == 1) ? 1 : 3)
var imagePublisher = 'OpenLogic'
var imageOffer = 'CentOS'
var solaceSecurityTemplateName = 'solaceSecurityTemplate'
var solaceLoadBalancerName = 'solaceLoadBalancerTemplate'
var solaceUpdateSubnetName = 'solaceUpdateSubnetTemplate'
var scriptsLocation = 'scripts/'
var solaceInstallScriptName = 'installSolace.sh'
var solaceInstallScriptFileUri = uri(_artifactsLocation, '${scriptsLocation}${solaceInstallScriptName}${_artifactsLocationSasToken}')
var sempQueryScriptName = 'sempQuery.sh'
var sempQueryScriptFileUri = uri(_artifactsLocation, '${scriptsLocation}${sempQueryScriptName}${_artifactsLocationSasToken}')
var publicIPAddressNameVM = 'myVmPublicIPD'
var publicIPAddressNameLB = 'myLbPublicIPD'
var publicIPAddressType = 'Dynamic'
var virtualNetworkName = ((!empty(existingVirtualNetworkName)) ? existingVirtualNetworkName : 'solaceVnet')
var subnetName = ((!empty(existingSubnetName)) ? existingSubnetName : 'solaceSubnet')
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
var nicName = 'nicD'
var numberOfNodes = {
  HighAvailability: 3
  SingleNode: 1
}
var numberOfInstances = numberOfNodes[deploymentModel]
var monitorNodeIndex = 2
var lbName = 'solaceHaGroupLoadBalancer'
var lbPoolName = 'solaceHaGroup'
var lbPoolID = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, lbPoolName)
var dataDisksChoices = {
  '0': [
    {
      name: '${dnsLabelForVmIp}0DataDisk'
      diskSizeGB: dataDiskSize
      lun: 0
      caching: 'ReadWrite'
      createOption: 'Empty'
      managedDisk: {
        storageAccountType: 'StandardSSD_LRS'
      }
    }
  ]
  '1': [
    {
      name: '${dnsLabelForVmIp}1DataDisk'
      diskSizeGB: dataDiskSize
      lun: 0
      caching: 'ReadWrite'
      createOption: 'Empty'
      managedDisk: {
        storageAccountType: 'StandardSSD_LRS'
      }
    }
  ]
}
var adminPasswordDir = '/mnt/resource/secrets'
var adminPasswordFile = '${adminPasswordDir}/solOSpasswd'
var useLogAnalytics = (!empty(workspaceName))
var logAnalyticsResourceName = (useLogAnalytics ? workspaceName : 'ignored')
var workspaceTier = 'Free'
var containersMarketplaceName = 'Containers'
var syslogFacilities = [
  'kern'
  'user'
  'daemon'
  'auth'
  'syslog'
  'uucp'
  'authpriv'
  'ftp'
  'cron'
  'local0'
  'local1'
  'local2'
  'local3'
  'local4'
  'local5'
  'local6'
  'local7'
]

module solaceSecurityTemplate 'modules/security-shared-resources.bicep' = {
  name: solaceSecurityTemplateName
  params: {
    securityGroupName: securityGroupName
    subnetPrefix: subnetPrefix
    location: location
  }
}

module solaceLoadBalancer 'modules/loadbalancer-shared-resources.bicep' = {
  name: solaceLoadBalancerName
  params: {
    exposure: vmAndLoadbalancerExposure
    dnsLabelForPublicLoadBalancer: dnsLabelForPublicLoadBalancer
    publicIpAddressName: publicIPAddressNameLB
    publicIpAddressType: publicIPAddressType
    lbName: lbName
    lbPoolName: lbPoolName
    subnetRef: subnetRef
    location: location
  }
}

resource logAnalyticsResource 'Microsoft.OperationalInsights/workspaces@2022-10-01' = if (useLogAnalytics) {
  name: logAnalyticsResourceName
  location: workspaceRegion
  properties: {
    sku: {
      name: workspaceTier
    }
  }
}

resource logAnalyticsResourceName_syslogCollection 'Microsoft.OperationalInsights/workspaces/datasources@2020-08-01' = if (useLogAnalytics) {
  parent: logAnalyticsResource
  name: 'syslogCollection'
  kind: 'LinuxSyslogCollection'
  properties: {
    state: 'Enabled'
  }
}

resource logAnalyticsResourceName_syslog 'Microsoft.OperationalInsights/workspaces/dataSources@2020-08-01' = [for (item, i) in syslogFacilities: if (useLogAnalytics) {
  parent: logAnalyticsResource
  name: 'syslog${i}'
  kind: 'LinuxSyslog'
  properties: {
    syslogName: item
    syslogSeverities: [
      {
        severity: 'emerg'
      }
      {
        severity: 'alert'
      }
      {
        severity: 'crit'
      }
      {
        severity: 'err'
      }
      {
        severity: 'warning'
      }
    ]
  }
}]

resource containersMarketplaceName_logAnalyticsResource 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (useLogAnalytics) {
  name: '${containersMarketplaceName}(${logAnalyticsResourceName})'
  location: workspaceRegion
  properties: {
    workspaceResourceId: logAnalyticsResource.id
  }
  plan: {
    name: '${containersMarketplaceName}(${logAnalyticsResourceName})'
    publisher: 'Microsoft'
    product: 'OMSGallery/${containersMarketplaceName}'
    promotionCode: ''
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = [for i in range(0, numberOfInstances): if (vmAndLoadbalancerExposure == 'Public') {
  name: '${publicIPAddressNameVM}${i}'
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAddressType
    dnsSettings: {
      domainNameLabel: '${dnsLabelForVmIp}${i}'
    }
  }
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = if (empty(existingSubnetName)) {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
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

module solaceUpdateSubnet 'modules/update-subnet-shared-resources.bicep' = {
  name: solaceUpdateSubnetName
  params: {
    virtualNetworkName: virtualNetworkName
    subnetName: subnetName
    subnetAddressPrefix: virtualNetwork.properties.subnets[0].properties.addressPrefix
    nsgId: resourceId('Microsoft.Network/networkSecurityGroups', securityGroupName)
  }
  dependsOn: [
    solaceSecurityTemplate
  ]
}

resource publicNic 'Microsoft.Network/networkInterfaces@2023-04-01' = [for i in range(0, numberOfInstances): if (vmAndLoadbalancerExposure == 'Public') {
  name: 'public${nicName}${i}'
  location: location
  properties: {
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', securityGroupName)
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddressNameVM}${i}')
          }
          subnet: {
            id: subnetRef
          }
          loadBalancerBackendAddressPools: [
            {
              id: lbPoolID
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    publicIPAddress[i]
    virtualNetwork
    solaceLoadBalancer
  ]
}]

resource internalNic 'Microsoft.Network/networkInterfaces@2023-04-01' = [for i in range(0, numberOfInstances): if (vmAndLoadbalancerExposure != 'Public') {
  name: 'internal${nicName}${i}'
  location: location
  properties: {
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', securityGroupName)
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
          loadBalancerBackendAddressPools: [
            {
              id: lbPoolID
            }
          ]
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
    solaceLoadBalancer
  ]
}]

resource availabilitySet 'Microsoft.Compute/availabilitySets@2023-03-01' = {
  name: availabilitySetName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: platformFaultDomainCount
    platformUpdateDomainCount: platformUpdateDomainCount
  }
}

resource dnsLabelForVmIpResource 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, numberOfInstances): {
  name: '${dnsLabelForVmIp}${i}'
  location: location
  properties: {
    availabilitySet: {
      id: availabilitySet.id
    }
    hardwareProfile: {
      vmSize: ((i == monitorNodeIndex) ? monitorNodeVmSize : messageRoutingNodeVmSize)
    }
    osProfile: {
      computerName: '${dnsLabelForVmIp}${i}'
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: centosVersion
        version: 'latest'
      }
      osDisk: {
        name: '${dnsLabelForVmIp}${i}OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
      dataDisks: (((dataDiskSize == '0') || (i == monitorNodeIndex)) ? null : dataDisksChoices[string(i)])
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmAndLoadbalancerExposure}${nicName}${i}')
        }
      ]
    }
  }
}]

resource dnsLabelForVmIpDockerExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, numberOfInstances): {
  parent: dnsLabelForVmIpResource[i]
  name: 'DockerExtension'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'DockerExtension'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}]

resource dnsLabelForVmIpOmsAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, numberOfInstances): if (useLogAnalytics) {
  parent: dnsLabelForVmIpResource[i]
  name: 'OmsAgentExtension'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
    typeHandlerVersion: '1.4'
    settings: {
      workspaceId: ((!useLogAnalytics) ? '' : logAnalyticsResource.properties.customerId)
    }
    protectedSettings: {
      workspaceKey: ((!useLogAnalytics) ? '' : logAnalyticsResource.listKeys().primarySharedKey)
    }
  }
}]

resource dnsLabelForVmIpConfigureSolaceContainer 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for i in range(0, numberOfInstances): {
  parent: dnsLabelForVmIpResource[i]
  name: 'configureSolaceContainer'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        solaceInstallScriptFileUri
        sempQueryScriptFileUri
      ]
    }
    protectedSettings: {
      commandToExecute: 'mkdir -p -m 770 ${adminPasswordDir}; echo ${solaceAdminPassword} > ${adminPasswordFile}; bash ${solaceInstallScriptName} -c ${i} -d ${dnsLabelForVmIp} -i ${numberOfInstances} -p ${adminPasswordFile} -n ${maxNumberOfClientConnections} -q ${maxNumberOfQueueMessages} -s ${((i == monitorNodeIndex) ? '0' : dataDiskSize)}${((!useLogAnalytics) ? '' : ' -w ${logAnalyticsResource.properties.customerId}')} -u ${brokerDockerImageReference}'
    }
  }
}]
