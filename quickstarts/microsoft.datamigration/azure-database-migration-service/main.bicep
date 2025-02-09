@description('Location where the resources will be deployed.')
param location string = resourceGroup().location

@description('Do you want to create a public IP address for the source server?')
param createPublicIP bool = true

@description('Windows Authentication user name for the source server')
param sourceWindowsAdminUserName string

@description('Windows Authentication password for the source server')
@secure()
param sourceWindowsAdminPassword string

@description('Sql Authentication password for the source server (User name will be same as Windows Auth)')
@secure()
param sourceSqlAuthenticationPassword string

@description('Source VM size')
param vmSize string = 'Standard_D8s_v3'

@description('Administrator User name for the Target Azure SQL DB Server.')
param targetSqlDbAdministratorLogin string

@description('Administrator Password for the Target Azure SQL DB Server.')
@secure()
param targetSqlDbAdministratorPassword string

@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
param _artifactsLocation string = deployment().properties.templateLink.uri

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
@secure()
param _artifactsLocationSasToken string = ''

var DMSServiceName = 'DMS${uniqueString(resourceGroup().id)}'
var sourceServerName = take('Source${uniqueString(resourceGroup().id)}', 15)
var targetServerName = 'targetservername${uniqueString(resourceGroup().id)}'
var scriptLocation = 'AddDatabaseToSqlServer.ps1'
var bakFileLocation = 'AdventureWorks2016.bak'
var scriptFiles = [
  uri(_artifactsLocation, '${scriptLocation}{_artifactsLocationSasToken}')
  uri(_artifactsLocation, '${bakFileLocation}{_artifactsLocationSasToken}')
]
var scriptParameters = '-userName ${sourceWindowsAdminUserName} -password "${sourceWindowsAdminPassword}'
var storageAccountName = toLower('store${uniqueString(resourceGroup().id)}')
var sourceNicName = 'SourceNIC-1'
var publicIPSourceServerName = 'SourceServer1-ip'
var sourceServerNSGName = 'SourceServer1-nsg'
var adVNetName = 'AzureDataMigrationServiceTemplateRG-vnet'
var defaultSubnetName = 'default'
var databaseName = 'TargetDatabaseName1'
var publicIpAddressId = {
  id: publicIPSourceServer.id
}

resource sourceServerVM 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: sourceServerName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'SQL2016SP1-WS2016'
        sku: 'Standard'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 127
      }
      dataDisks: [
        {
          lun: 0
          name: '${sourceServerName}_disk-1'
          createOption: 'Empty'
          caching: 'ReadOnly'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          diskSizeGB: 1023
        }
      ]
    }
    osProfile: {
      computerName: sourceServerName
      adminUsername: sourceWindowsAdminUserName
      adminPassword: sourceWindowsAdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: sourceNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(storageAccountName, '2019-06-01').primaryEndpoints.blob
      }
    }
  }
}

resource sqlIaasExtension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: sourceServerVM
  name: 'SqlIaasExtension'
  location: location
  properties: {
    type: 'SqlIaaSAgent'
    publisher: 'Microsoft.SqlServer.Management'
    typeHandlerVersion: '1.2'
    autoUpgradeMinorVersion: true
    settings: {
      AutoTelemetrySettings: {
        Region: location
      }
      AutoPatchingSettings: {
        PatchCategory: 'WindowsMandatoryUpdates'
        Enable: false
        DayOfWeek: 'Sunday'
        MaintenanceWindowStartingHour: '2'
        MaintenanceWindowDuration: '60'
      }
      KeyVaultCredentialSettings: {
        Enable: false
      }
      ServerConfigurationsManagementSettings: {
        SQLConnectivityUpdateSettings: {
          ConnectivityType: 'Private'
          Port: '1433'
        }
        SQLWorkloadTypeUpdateSettings: {
          SQLWorkloadType: 'OLTP'
        }
        SQLStorageUpdateSettings: {
          DiskCount: '1'
          NumberOfColumns: '8'
          StartingDeviceID: '2'
          DiskConfigurationType: 'NEW'
        }
        AdditionalFeaturesServerConfigurations: {
          IsRServicesEnabled: 'false'
        }
      }
    }
    protectedSettings: {
      SQLAuthUpdateUserName: sourceWindowsAdminUserName
      SQLAuthUpdatePassword: sourceSqlAuthenticationPassword
    }
  }
}

resource customScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  parent: sourceServerVM
  name: 'CustomScriptExtension'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: scriptFiles
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ./${scriptLocation} ${scriptParameters}'
    }
  }
  dependsOn: [

    sqlIaasExtension
  ]
}

resource DMSService 'Microsoft.DataMigration/services@2022-03-30-preview' = {
  name: DMSServiceName
  location: location
  sku: {
    name: 'Standard_4vCores'
    tier: 'Standard'
    size: '4 vCores'
  }
  properties: {
    virtualSubnetId: adVNet_defaultSubnet.id
  }
}

resource sqlToSqlDbMigrationProject 'Microsoft.DataMigration/services/projects@2022-03-30-preview' = {
  parent: DMSService
  name: 'SqlToSqlDbMigrationProject'
  location: location
  properties: {
    sourcePlatform: 'SQL'
    targetPlatform: 'SQLDB'
  }
}

resource sourceNic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: sourceNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: adVNet_defaultSubnet.id
          }
          publicIPAddress: (createPublicIP ? publicIpAddressId : json('null'))
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

resource sourceServerNSG 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: sourceServerNSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowVnetInBound'
        properties: {
          description: 'Allow inbound traffic from all VMs in VNET'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 4000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInBound'
        properties: {
          description: 'Allow inbound traffic from azure load balancer'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 4001
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          description: 'Deny all inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4050
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowVnetOutBound'
        properties: {
          description: 'Allow outbound traffic from all VMs to all VMs in VNET'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 4000
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowInternetOutBound'
        properties: {
          description: 'Allow outbound traffic from all VMs to Internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 4001
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          description: 'Deny all outbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4050
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource publicIPSourceServer 'Microsoft.Network/publicIPAddresses@2022-05-01' = if (createPublicIP) {
  name: publicIPSourceServerName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
  }
}

resource adVNet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: adVNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/24'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.2.0.0/24'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource adVNet_defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  parent: adVNet
  name: defaultSubnetName
  properties: {
    addressPrefix: '10.2.0.0/24'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource targetServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: targetServerName
  location: location
  properties: {
    administratorLogin: targetSqlDbAdministratorLogin
    administratorLoginPassword: targetSqlDbAdministratorPassword
    version: '12.0'
  }
}

resource targetServerDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: targetServer
  name: databaseName
  location: location
  sku: {
    name: 'S3'
    tier: 'Standard'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
    zoneRedundant: false
  }
}

resource import 'Microsoft.Sql/servers/databases/extensions@2022-05-01-preview' = {
  parent: targetServerDatabase
  name: 'Import'
  properties: {
    storageKey: _artifactsLocationSasToken
    storageKeyType: 'SharedAccessKey'
    storageUri: uri(_artifactsLocation, 'templatefiles/AdventureWorks2016.bacpac')
    administratorLogin: targetSqlDbAdministratorLogin
    administratorLoginPassword: targetSqlDbAdministratorPassword
    operationMode: 'Import'
  }
}

resource allowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: targetServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}
