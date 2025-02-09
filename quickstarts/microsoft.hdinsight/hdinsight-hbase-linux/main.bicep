@description('The name of the HDInsight cluster to create.')
param clusterName string

@description('These credentials can be used to submit jobs to the cluster and to log into cluster dashboards.')
param clusterLoginUserName string

@description('The password must be at least 10 characters in length and must contain at least one digit, one upper case letter, one lower case letter, and one non-alphanumeric character except (single-quote, double-quote, backslash, right-bracket, full-stop). Also, the password must not contain 3 consecutive characters from the cluster username or SSH username.')
@minLength(10)
@secure()
param clusterLoginPassword string

@description('These credentials can be used to remotely access the cluster.')
param sshUserName string

@description('SSH password must be 6-72 characters long and must contain at least one digit, one upper case letter, and one lower case letter.  It must not contain any 3 consecutive characters from the cluster login name')
@minLength(6)
@maxLength(72)
@secure()
param sshPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('This is the headnode Azure Virtual Machine size, and will affect the cost. If you don\'t know, just leave the default value.')
@allowed([
  'Standard_A4_v2'
  'Standard_A8_v2'
  'Standard_E2_v3'
  'Standard_E4_v3'
  'Standard_E8_v3'
  'Standard_E16_v3'
  'Standard_E20_v3'
  'Standard_E32_v3'
  'Standard_E48_v3'
])
param HeadNodeVirtualMachineSize string = 'Standard_E4_v3'

@description('This is the worerdnode Azure Virtual Machine size, and will affect the cost. If you don\'t know, just leave the default value.')
@allowed([
  'Standard_A4_v2'
  'Standard_A8_v2'
  'Standard_E2_v3'
  'Standard_E4_v3'
  'Standard_E8_v3'
  'Standard_E16_v3'
  'Standard_E20_v3'
  'Standard_E32_v3'
  'Standard_E48_v3'
])
param WorkerNodeVirtualMachineSize string = 'Standard_E4_v3'

@description('This is the Zookeepernode Azure Virtual Machine size, and will affect the cost. If you don\'t know, just leave the default value.')
@allowed([
  'Standard_A4_v2'
  'Standard_A8_v2'
  'Standard_E2_v3'
  'Standard_E4_v3'
  'Standard_E8_v3'
  'Standard_E16_v3'
  'Standard_E20_v3'
  'Standard_E32_v3'
  'Standard_E48_v3'
])
param ZookeeperNodeVirtualMachineSize string = 'Standard_E4_v3'

var defaultStorageAccount = {
  name: uniqueString(resourceGroup().id)
  type: 'Standard_LRS'
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: defaultStorageAccount.name
  location: location
  sku: {
    name: defaultStorageAccount.type
  }
  kind: 'Storage'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
  }
}

resource cluster 'Microsoft.HDInsight/clusters@2023-08-15-preview' = {
  name: clusterName
  location: location
  properties: {
    clusterVersion: '4.0'
    osType: 'Linux'
    clusterDefinition: {
      kind: 'hbase'
      configurations: {
        gateway: {
          'restAuthCredential.isEnabled': true
          'restAuthCredential.username': clusterLoginUserName
          'restAuthCredential.password': clusterLoginPassword
        }
      }
    }
    storageProfile: {
      storageaccounts: [
        {
          name: replace(replace(reference(storageAccount.id, '2021-08-01').primaryEndpoints.blob, 'https://', ''), '/', '')
          isDefault: true
          container: clusterName
          key: listKeys(storageAccount.id, '2021-08-01').keys[0].value
        }
      ]
    }
    computeProfile: {
      roles: [
        {
          name: 'headnode'
          targetInstanceCount: 2
          hardwareProfile: {
            vmSize: HeadNodeVirtualMachineSize
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: sshUserName
              password: sshPassword
            }
          }
        }
        {
          name: 'workernode'
          targetInstanceCount: 2
          hardwareProfile: {
            vmSize: WorkerNodeVirtualMachineSize
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: sshUserName
              password: sshPassword
            }
          }
        }
        {
          name: 'zookeepernode'
          targetInstanceCount: 3
          hardwareProfile: {
            vmSize: ZookeeperNodeVirtualMachineSize
          }
          osProfile: {
            linuxOperatingSystemProfile: {
              username: sshUserName
              password: sshPassword
            }
          }
        }
      ]
    }
  }
}

output cluster object = cluster.properties
