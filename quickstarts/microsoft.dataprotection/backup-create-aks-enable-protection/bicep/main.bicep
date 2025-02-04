targetScope = 'subscription'

param resource_prefix string
param resource_location string
param staging_resource_location string
param resource_tags object

var hub_resource_group_name = '${resource_prefix}-hub-rg'
var aks_resource_group_name = '${resource_prefix}-aks-rg'
var snapshot_resource_group_name = '${resource_prefix}-snapshot-rg'
var staging_resource_group_name = '${resource_prefix}-staging-rg'
var hub_law_name = '${resource_prefix}-hub-law'
var aks_law_name = '${resource_prefix}-aks-law'
var fw_vnet_name = '${resource_prefix}-fw-vnet'
var fw_vnet_address_prefix = '10.128.0.0/24'
var fw_name = '${resource_prefix}-hub-fw'
var fw_route_table_name = '${resource_prefix}-hub-fw-routes'
var des_uai_name = '${resource_prefix}-aks-des-uai'
var des_name = '${resource_prefix}-aks-des'
var aks_spoke_vnet_name = '${resource_prefix}-aks-vnet'
var aks_spoke_vnet_nsg_name = '${resource_prefix}-aks-vnet-nsg'
var aks_spoke_vnet_address_prefix = '10.129.0.0/16'
var aks_uai_name = '${resource_prefix}-aks-uai'
var key_vault_name = '${resource_prefix}akv'
var kv_des_encryption_key_name = 'des-encryption-key'
var kv_kms_encryption_plugin_key_name = 'kms-encryption-plugin-key'
var private_dns_zone_name = '${resource_prefix}-pdz.azure.com'
var aks_name = '${resource_prefix}-aks'
var aks_backup_storage_name = '${resource_prefix}backupstor'
var aks_staging_storage_name = '${resource_prefix}stagingstor'
var aks_backup_vault_name = '${resource_prefix}-backup-vault'
var aks_kubernetes_version = '1.27'
//var aks_persistent_managed_disk_name = '${resource_prefix}-persistent-disk'

module hub_resource_group_module '../../../modules/resource-group.bicep' = {
  name: 'hub_resource_group_module'
  params: {
    name: hub_resource_group_name
    location: resource_location
    tags: resource_tags
  }
}

module aks_resource_group_module '../../../modules/resource-group.bicep' = {
  name: 'aks_resource_group_module'
  params: {
    name: aks_resource_group_name
    location: resource_location
    tags: resource_tags
  }
}

module snapshot_resource_group_module '../../../modules/resource-group.bicep' = {
  name: 'snapshot_resource_group_module'
  params: {
    name: snapshot_resource_group_name
    location: resource_location
    tags: resource_tags
  }
}

module staging_resource_group_module '../../../modules/resource-group.bicep' = {
  name: 'staging_resource_group_module'
  params: {
    name: staging_resource_group_name
    location: staging_resource_location
    tags: resource_tags
  }
}

module hub_law_module '../../../modules/log-analytics-workspace.bicep' = {
  scope: resourceGroup(hub_resource_group_name)
  name: 'hub_law_module'
  params: {
    name: hub_law_name
    location: resource_location
    tags: resource_tags
  }
  dependsOn: [
    hub_resource_group_module
  ]
}

module aks_law_module '../../../modules/log-analytics-workspace.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'aks_law_module'
  params: {
    name: aks_law_name
    location: resource_location
    tags: resource_tags
  }
  dependsOn: [
    aks_resource_group_module
  ]
}

module des_uai_module '../../../modules/user-assigned-identity.bicep' = {
  name: 'des_uai_module'
  params: {
    name: des_uai_name
    location: resource_location
    tags: resource_tags
  }
  scope: resourceGroup(aks_resource_group_name)
  dependsOn: [
    aks_resource_group_module
  ]
}

module aks_uai_module '../../../modules/user-assigned-identity.bicep' = {
  name: 'aks_uai_module'
  params: {
    name: aks_uai_name
    location: resource_location
    tags: resource_tags
  }
  scope: resourceGroup(aks_resource_group_name)
  dependsOn: [
    aks_resource_group_module
  ]
}

module private_dns_zone_module '../../../modules/private-dns-zone.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'private_dns_zone_module'
  params: {
    name: private_dns_zone_name
    tags: resource_tags
  }
  dependsOn: [
    aks_resource_group_module
  ]
}

module fw_hub_vnet_module '../../../modules/virtual-network.bicep' = {
  name: 'fw_hub_vnet_module'
  params: {
    addressPrefix: fw_vnet_address_prefix
    name: fw_vnet_name
    location: resource_location
    tags: resource_tags
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.128.0.0/26'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.128.0.64/27'
        }
      }
    ]
  }
  scope: resourceGroup(hub_resource_group_name)
  dependsOn: [
    hub_resource_group_module
    hub_law_module
  ]
}

module fw_module '../../../modules/firewall.bicep' = {
  name: 'fw_module'
  params: {
    name: fw_name
    location: resource_location
    logAnalyticsWorkspaceId: hub_law_module.outputs.id
    subnetId: first(filter(fw_hub_vnet_module.outputs.subnets, x => x.name == 'AzureFirewallSubnet')).?id
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
    availabilityZones: [ '1', '2', '3' ]
    publicIps: [ '1', '2', '3' ]
    tags: resource_tags

    defaultNetworkRuleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'aks-firewall-network-rules'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'aks-api-udp'
            ipProtocols: [ 'UDP' ]
            sourceAddresses: [ '*' ]
            destinationAddresses: [ 'AzureCloud.${resource_location}' ]
            destinationFqdns: []
            destinationPorts: [ '1194', '53' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'aks-api-tcp'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: [ '*' ]
            destinationAddresses: [ 'AzureCloud.${resource_location}' ]
            destinationFqdns: []
            destinationPorts: [ '9000' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'aks-time-sync'
            ipProtocols: [ 'UDP' ]
            sourceAddresses: [ '*' ]
            destinationAddresses: [ 'ntp.ubuntu.com' ]
            destinationFqdns: []
            destinationPorts: [ '123' ]
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'azure-services-firewall-network-rules'
        priority: 101
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'azure-storage-tcp'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: [ '*' ]
            destinationAddresses: [ 'Storage' ]
            destinationPorts: [ '443' ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'azure-monitor-tcp'
            ipProtocols: [ 'TCP' ]
            sourceAddresses: [ '*' ]
            destinationAddresses: [ 'AzureMonitor' ]
            destinationPorts: [ '443' ]
          }
        ]
      }
    ]
    defaultApplicationRuleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'aks-firewall-application-rules'
        action: {
          type: 'Allow'
        }
        priority: 100
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'aks-fqdn'
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            sourceAddresses: [ '*' ]
            destinationAddresses: []
            fqdnTags: [
              'AzureKubernetesService'
            ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'aks-container-registries'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [ '*.docker.com', '*.docker.io', 'mcr.microsoft.com', '*.azurecr.io', '*ghcr.io', '*.githubusercontent.com' ]
            sourceAddresses: [ '*' ]
          }
          {
            ruleType: 'ApplicationRule'
            name: 'aks-extension-dataplane'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [ '*.dp.kubernetesconfiguration.azure.com' ]
            sourceAddresses: [ '*' ]
          }
        ]
      }
    ]
  }
  scope: resourceGroup(hub_resource_group_name)
  dependsOn: [
    hub_resource_group_module
    hub_law_module
    fw_hub_vnet_module
  ]
}

module fw_route_table_module '../../../modules/route-table.bicep' = {
  name: 'fw_route_table_module'
  params: {
    name: fw_route_table_name
    location: resource_location
    tags: resource_tags
    routes: [
      {
        name: 'route-spoke-to-firewall'
        properties: {
          nextHopType: 'VirtualAppliance'
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: fw_module.outputs.nextHopPrivateIpAddress
        }
      }
      {
        name: 'route-firewall-to-internet'
        properties: {
          nextHopType: 'Internet'
          addressPrefix: '${fw_module.outputs.publicIpAddress}/32'
        }
      }
    ]
  }
  scope: resourceGroup(hub_resource_group_name)
  dependsOn: [
    hub_resource_group_module
    fw_module
  ]
}

module aks_spoke_vnet_nsg_module '../../../modules/network-security-group.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'aks_spoke_vnet_nsg_module'
  params: {
    location: resource_location
    name: aks_spoke_vnet_nsg_name
    securityRules: [
      {
        name: 'AllowCorpnet'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 2700
          protocol: '*'
          sourceAddressPrefix: 'CorpNetPublic'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
      {
        name: 'AllowSAW'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 2701
          protocol: '*'
          sourceAddressPrefix: 'CorpNetSaw'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
    tags: resource_tags
  }
}

module aks_spoke_vnet_module '../../../modules/virtual-network.bicep' = {
  name: 'aks_spoke_vnet_module'
  params: {
    addressPrefix: aks_spoke_vnet_address_prefix
    name: aks_spoke_vnet_name
    location: resource_location
    tags: resource_tags
    subnets: [
      {
        name: 'aks-nodes-subnet'
        properties: {
          addressPrefix: '10.129.0.0/22'
          routeTable: {
            id: fw_route_table_module.outputs.id
          }
          networkSecurityGroup: {
            id: aks_spoke_vnet_nsg_module.outputs.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'aks-pods-subnet'
        properties: {
          addressPrefix: '10.129.4.0/22'
          routeTable: {
            id: fw_route_table_module.outputs.id
          }
          networkSecurityGroup: {
            id: aks_spoke_vnet_nsg_module.outputs.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          delegations: [
            {
              name: 'Microsoft.ContainerService.managedClusters'
              properties: {
                serviceName: 'Microsoft.ContainerService/managedClusters'
              }
            }
          ]
        }
      }
      {
        name: 'aks-api-server-subnet'
        properties: {
          addressPrefix: '10.129.8.0/22'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          routeTable: {
            id: fw_route_table_module.outputs.id
          }
          networkSecurityGroup: {
            id: aks_spoke_vnet_nsg_module.outputs.id
          }
          delegations: [
            {
              name: 'Microsoft.ContainerService.managedClusters'
              properties: {
                serviceName: 'Microsoft.ContainerService/managedClusters'
              }
            }
          ]
        }
      }
      {
        name: 'private-endpoints-subnet'
        properties: {
          addressPrefix: '10.129.12.0/26'
          networkSecurityGroup: {
            id: aks_spoke_vnet_nsg_module.outputs.id
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    roleAssignments: [
      {
        subnetName: 'aks-nodes-subnet'
        principalId: aks_uai_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') //Network Contributor
      }
      {
        subnetName: 'aks-pods-subnet'
        principalId: aks_uai_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') //Network Contributor
      }
      {
        subnetName: 'aks-api-server-subnet'
        principalId: aks_uai_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') //Network Contributor
      }
      {
        subnetName: 'private-endpoints-subnet'
        principalId: aks_uai_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') //Network Contributor
      }
    ]
  }
  scope: resourceGroup(aks_resource_group_name)
  dependsOn: [
    aks_resource_group_module
    aks_uai_module
    fw_route_table_module
    fw_module
  ]
}

module fw_hub_vnet_to_aks_spoke_vnet_peering_module '../../../modules/virtual-network-peering.bicep' = {
  name: 'fw_hub_vnet_to_aks_spoke_vnet_peering_module'
  params: {
    vnetAName: fw_vnet_name
    vnetBName: aks_spoke_vnet_name
    vnetBId: aks_spoke_vnet_module.outputs.id
  }
  scope: resourceGroup(hub_resource_group_name)
  dependsOn: [
    hub_resource_group_module
    fw_hub_vnet_module
    aks_spoke_vnet_module
  ]
}

module aks_spoke_vnet_to_fw_hub_vnet_peering_module '../../../modules/virtual-network-peering.bicep' = {
  name: 'aks_spoke_vnet_to_fw_hub_vnet_peering_module'
  params: {
    vnetAName: aks_spoke_vnet_name
    vnetBName: fw_vnet_name
    vnetBId: fw_hub_vnet_module.outputs.id
  }
  scope: resourceGroup(aks_resource_group_name)
  dependsOn: [
    aks_resource_group_module
    fw_hub_vnet_module
    aks_spoke_vnet_module
  ]
}

module key_vault_module '../../../modules/key-vault.bicep' = {
  name: 'key_vault_module'
  params: {
    name: key_vault_name
    location: resource_location
    tags: resource_tags
    sku: 'Premium'
    enabledForDiskEncryption: true
    roleAssignments: [
      {
        principalId: des_uai_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6') //Key Vault Crypto Service Encryption User
      }
      {
        principalId: aks_uai_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424') //Key Vault Crypto User
      }
      {
        principalId: aks_uai_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'f25e0fa2-a7c8-4377-a976-54943a77a395') //Key Vault Contributor
      }
    ]
  }
  scope: resourceGroup(aks_resource_group_name)
  dependsOn: [
    aks_resource_group_module
    aks_uai_module
    des_uai_module
  ]
}

module kv_private_endpoint_module '../../../modules/private-endpoint.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'kv_private_endpoint_module'
  params: {
    location: resource_location
    name: '${key_vault_name}-pe'
    parentResourceId: key_vault_module.outputs.id
    subnetId: first(filter(aks_spoke_vnet_module.outputs.subnets, x => x.name == 'private-endpoints-subnet')).?id
    privateDnsZoneId: private_dns_zone_module.outputs.id
    privateDnsZoneName: private_dns_zone_name
    tags: resource_tags
  }
}

module kv_des_encryption_key_module '../../../modules/key-vault-key.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'kv_des_encryption_key_module'
  params: {
    name: kv_des_encryption_key_name
    tags: resource_tags
    keyVaultName: key_vault_name
    keyType: 'RSA-HSM'
  }
  dependsOn: [
    aks_resource_group_module
    key_vault_module
  ]
}

module kv_kms_encryption_plugin_key_module '../../../modules/key-vault-key.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'kv_kms_encryption_plugin_key_module'
  params: {
    name: kv_kms_encryption_plugin_key_name
    tags: resource_tags
    keyVaultName: key_vault_name
    keyType: 'RSA-HSM'
  }
  dependsOn: [
    aks_resource_group_module
    key_vault_module
  ]
}

module disk_encryption_set_module '../../../modules/disk-encryption-set.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'disk_encryption_set_module'
  params: {
    keyUrl: kv_des_encryption_key_module.outputs.keyUrlWithVersion
    keyVaultId: key_vault_module.outputs.id
    location: resource_location
    name: des_name
    tags: resource_tags
    userAssignedIdentityId: des_uai_module.outputs.id
  }
  dependsOn: [
    aks_resource_group_module
    kv_des_encryption_key_module
    des_uai_module
  ]
}

module aks_module '../../../modules/aks-cluster.bicep' = {
  name: 'aks_module'
  params: {
    name: aks_name
    location: resource_location
    kubernetesVersion: aks_kubernetes_version
    diskEncryptionSetID: disk_encryption_set_module.outputs.id
    tags: resource_tags

    enableUptimeSLA: true
    disableLocalAccounts: false
    apiServer: {
      enableVnetIntegration: true
      subnetId: first(filter(aks_spoke_vnet_module.outputs.subnets, x => x.name == 'aks-api-server-subnet')).?id
    }
    aadProfile: {
      enableAzureRBAC: true
      managed: true
    }
    clusterIdentityProfile: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${aks_uai_module.outputs.id}': {}
      }
    }
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          useAADAuth: 'true'
          logAnalyticsWorkspaceResourceID: aks_law_module.outputs.id
        }
      }
      azurepolicy: {
        enabled: true
        config: {
          version: 'v2'
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
          rotationPollInterval: '2m'
        }
      }
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      outboundType: 'loadBalancer'
      loadBalancerSku: 'standard'
    }
    securityProfile: {
      imageCleaner: {
        enabled: true
        intervalHours: 24
      }
      workloadIdentity: {
        enabled: true
      }
      defender: {
        securityMonitoring: {
          enabled: true
        }
        logAnalyticsWorkspaceResourceId: aks_law_module.outputs.id
      }
      azureKeyVaultKms: {
        enabled: true
        keyId: kv_des_encryption_key_module.outputs.keyUrlWithVersion
        keyVaultResourceId: kv_des_encryption_key_module.outputs.keyVaultId
        keyVaultNetworkAccess: 'Private'
      }
    }
    serviceMeshProfile: {
      mode: 'Istio'
      istio: {
        components: {
          ingressGateways: [
            {
              enabled: true
              mode: 'External'
            }
            {
              enabled: true
              mode: 'Internal'
            }
          ]
        }
      }
    }
    storageProfile: {
      blobCSIDriver: {
        enabled: false
      }
      diskCSIDriver: {
        enabled: true
      }
      fileCSIDriver: {
        enabled: false
      }
      snapshotController: {
        enabled: true
      }
    }
    nodePools: [
      {
        name: 'kubesystem'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        vmSize: 'Standard_D8as_v5'
        osType: 'Linux'
        osSKU: 'Mariner'
        enableAutoScaling: true
        count: 3
        minCount: 3
        maxCount: 5
        availabilityZones: [ '1' ]
        vnetSubnetID: first(filter(aks_spoke_vnet_module.outputs.subnets, x => x.name == 'aks-nodes-subnet')).?id
        podSubnetID: first(filter(aks_spoke_vnet_module.outputs.subnets, x => x.name == 'aks-pods-subnet')).?id
        enableEncryptionAtHost: true
        upgradeSettings: {
          maxSurge: '10%'
        }
        nodeLabels: {}
        nodeTaints: []
        tags: resource_tags
      }
      {
        name: 'persistent1'
        mode: 'User'
        type: 'VirtualMachineScaleSets'
        vmSize: 'Standard_E8as_v5'
        osType: 'Linux'
        osSKU: 'AzureLinux'
        enableAutoScaling: true
        count: 3
        minCount: 3
        maxCount: 5
        availabilityZones: [ '1' ]
        vnetSubnetID: first(filter(aks_spoke_vnet_module.outputs.subnets, x => x.name == 'aks-nodes-subnet')).?id
        podSubnetID: first(filter(aks_spoke_vnet_module.outputs.subnets, x => x.name == 'aks-pods-subnet')).?id
        enableEncryptionAtHost: true
        upgradeSettings: {
          maxSurge: '10%'
        }
        nodeLabels: {}
        nodeTaints: []
        tags: resource_tags
      }
    ]
  }
  scope: resourceGroup(aks_resource_group_name)
  dependsOn: [
    aks_resource_group_module
    fw_module
    fw_route_table_module
    aks_spoke_vnet_module
    aks_uai_module
    disk_encryption_set_module
    kv_kms_encryption_plugin_key_module
    fw_hub_vnet_to_aks_spoke_vnet_peering_module
    aks_spoke_vnet_to_fw_hub_vnet_peering_module
    aks_law_module
  ]
}

module backup_storage_account_module '../../../modules/storage-account.bicep' = {
  scope: resourceGroup(snapshot_resource_group_name)
  name: 'backup_storage_account_module'
  params: {
    location: resource_location
    name: aks_backup_storage_name
    sku: {
      name: 'Standard_GRS'
    }
    tags: resource_tags
    containers: [
      {
        name: 'aks-backup'
        publicAccess: 'None'
      }
    ]
  }
  dependsOn: [
    snapshot_resource_group_module
  ]
}

module staging_storage_account_module '../../../modules/storage-account.bicep' = {
  scope: resourceGroup(staging_resource_group_name)
  name: 'staging_storage_account_module'
  params: {
    location: staging_resource_location
    name: aks_staging_storage_name
    sku: {
      name: 'Standard_GRS'
    }
    tags: resource_tags
    containers: [
      {
        name: 'aks-backup'
        publicAccess: 'None'
      }
    ]
  }
  dependsOn: [
    staging_resource_group_module
  ]
}

module aks_backup_extension_module '../../../modules/aks-cluster-extension.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'aks_backup_extension_module'
  params: {
    aks_cluster_name: aks_name
    name: 'aks-backup-extension'
    extension_type: 'microsoft.dataprotection.kubernetes'
    autoUpgradeMinorVersion: true
    releaseTrain: 'stable'
    extensionIdentityProfile: {
      type: 'SystemAssigned'
    }
    scope: {
      cluster: {
        releaseNamespace: 'dataprotection-microsoft'
      }
    }
    configurationSettings: {
      'configuration.backupStorageLocation.bucket': 'aks-backup'
      'configuration.backupStorageLocation.config.subscriptionId': subscription().subscriptionId
      'configuration.backupStorageLocation.config.resourceGroup': snapshot_resource_group_name
      'configuration.backupStorageLocation.config.storageAccount': aks_backup_storage_name
      // 'configuration.backupStorageLocation.config.storageAccountURI': backup_storage_account_module.outputs.primaryBlobEndpoint
      // 'configuration.backupStorageLocation.config.useAAD': true
      'credentials.tenantId': subscription().tenantId
    }
  }
  dependsOn: [
    aks_resource_group_module
    backup_storage_account_module
    aks_module
  ]
}

module backup_vault_module '../../../modules/backup-vault.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'backup_vault_module'
  params: {
    location: resource_location
    name: aks_backup_vault_name
    storageSettings: [
      {
        type: 'GeoRedundant'
        datastoreType: 'VaultStore'
      }
    ]
    replicatedRegions: [ staging_resource_location ]
    tags: resource_tags
  }
  dependsOn: [
    aks_resource_group_module
  ]
}

module aks_backup_storage_account_role_assignments_module '../../../modules/storage-account-role-assignment.bicep' = {
  scope: resourceGroup(snapshot_resource_group_name)
  name: 'aks_backup_storage_account_role_assignments_module'
  params: {
    storageAccountName: aks_backup_storage_name
    roleAssignments: [
      {
        principalId: aks_backup_extension_module.outputs.extensionProperties.aksAssignedIdentity.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') //Storage Blob Data Contributor
      }
      {
        principalId: backup_vault_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1') //Storage Blob Data Reader
      }
    ]
  }
  dependsOn: [
    backup_storage_account_module
    aks_backup_extension_module
  ]
}

module aks_staging_storage_account_role_assignments_module '../../../modules/storage-account-role-assignment.bicep' = {
  scope: resourceGroup(staging_resource_group_name)
  name: 'aks_staging_storage_account_role_assignments_module'
  params: {
    storageAccountName: aks_staging_storage_name
    roleAssignments: [
      {
        principalId: backup_vault_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab') //Storage Account Contributor
      }
      {
        principalId: backup_vault_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b') //Storage Blob Data Owner
      }
    ]
  }
  dependsOn: [
    staging_storage_account_module
    backup_vault_module
  ]
}

module backup_vault_aks_reader_role_assignment_module '../../../modules/aks-cluster-role-assignments.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'backup_vault_aks_reader_role_assignment_module'
  params: {
    clusterName: aks_name
    principalId: backup_vault_module.outputs.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') //Reader
  }
  dependsOn: [
    aks_module
    backup_vault_module
  ]
}

module snapshot_rg_role_assignment_module '../../../modules/resource-group-role-assignments.bicep' = {
  scope: resourceGroup(snapshot_resource_group_name)
  name: 'snapshot_rg_role_assignment_module'
  params: {
    resourceGroupName: snapshot_resource_group_name
    roleAssignments: [
      {
        principalId: backup_vault_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') //Reader
      }
      {
        principalId: backup_vault_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '959f8984-c045-4866-89c7-12bf9737be2e') //Data Operator for Managed Disks
      }
      {
        principalId: backup_vault_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '7efff54f-a5b4-42b5-a1c5-5411624893ce') //Disk Snapshot Contributor
      }
      {
        principalId: aks_uai_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') //Contributor
      }
      {
        principalId: aks_backup_extension_module.outputs.extensionProperties.aksAssignedIdentity.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') //Contributor
      }
    ]
  }
  dependsOn: [
    backup_vault_module
    aks_uai_module
  ]
}

module staging_rg_role_assignment_module '../../../modules/resource-group-role-assignments.bicep' = {
  scope: resourceGroup(staging_resource_group_name)
  name: 'staging_rg_role_assignment_module'
  params: {
    resourceGroupName: staging_resource_group_name
    roleAssignments: [
      {
        principalId: backup_vault_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') //Contributor
      }
      {
        principalId: aks_uai_module.outputs.principalId
        roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') //Contributor
      }
    ]
  }
  dependsOn: [
    backup_vault_module
  ]
}

module aks_backup_vault_trusted_access_role_binding_module '../../../modules/aks-cluster-trusted-access-role-binding.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'aks_backup_vault_trusted_access_role_binding_module'
  params: {
    name: 'aks-backup-vault-tarb'
    aksClusterName: aks_name
    sourceResourceId: backup_vault_module.outputs.id
    roles: [
      'Microsoft.DataProtection/backupVaults/backup-operator'
    ]
  }
  dependsOn: [
    aks_module
    backup_vault_module
    aks_backup_extension_module
  ]
}

module aks_backup_vault_instance_module '../../../modules/backup-vault-instance.bicep' = {
  scope: resourceGroup(aks_resource_group_name)
  name: 'aks_backup_vault_instance_module'
  params: {
    backup_vault_name: aks_backup_vault_name
    backupPolicyId: backup_vault_module.outputs.kubernetesServicesBackupPolicyId
    dataSourceInfo: {
      objectType: 'Datasource'
      datasourceType: 'Microsoft.ContainerService/managedClusters'
      resourceType: 'Microsoft.ContainerService/managedClusters'
      resourceName: aks_name
      resourceLocation: resource_location
      resourceID: aks_module.outputs.id
      resourceUri: aks_module.outputs.id
    }
    dataSourceSetInfo: {
      objectType: 'DatasourceSet'
      datasourceType: 'Microsoft.ContainerService/managedClusters'
      resourceType: 'Microsoft.ContainerService/managedClusters'
      resourceName: aks_name
      resourceLocation: resource_location
      resourceID: aks_module.outputs.id
      resourceUri: aks_module.outputs.id
    }
    dataSourceResourceGroupId: snapshot_resource_group_module.outputs.id
    name: 'aks-k8s-instance'
    tags: resource_tags
  }
  dependsOn: [
    aks_module
    backup_vault_module
    backup_storage_account_module
    backup_vault_aks_reader_role_assignment_module
    aks_backup_extension_module
    aks_backup_storage_account_role_assignments_module
    aks_backup_vault_trusted_access_role_binding_module
  ]
}
