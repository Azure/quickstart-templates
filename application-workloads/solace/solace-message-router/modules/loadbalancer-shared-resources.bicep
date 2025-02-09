@description('Either \'Public\' or \'Internal\'. Internal Load balancer is only available from the virtual network, no public IP created')
param exposure string

@description('Unique DNS Label for the Public IP used to access the Load Balancer.')
param dnsLabelForPublicLoadBalancer string

@description('Load Balancer Public IP Address Name.')
param publicIpAddressName string = 'myLBPublicIPD'

@description('Load Balancer Public IP Address Type.')
param publicIpAddressType string = 'Dynamic'

@description('Load Balancer Name.')
param lbName string = 'myLB'

@description('Load Balancer Backend Address Pool Name.')
param lbPoolName string = 'solace-ha-group'

@description('Load Balancer Private IP subnet.')
param subnetRef string = ''

@description('Location for all resources.')
param location string = resourceGroup().location

var frontEndIpConfigName = 'LoadBalancerFrontEnd'
var frontEndIpConfigId = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations',lbName, frontEndIpConfigName )
var backendPoolId = resourceId('Microsoft.Network/loadBalancers/backendAddressPools',lbName, lbPoolName)
var lbProbeName = 'solace-ha-ad-health-check'
var healthProbeId = resourceId('Microsoft.Network/loadBalancers/probes',lbName, lbProbeName)
var publicIpAddress = {
  id: publicIpAddressResource.id
}
var subnet = {
  id: subnetRef
}

resource publicIpAddressResource 'Microsoft.Network/publicIPAddresses@2023-04-01' = if (exposure == 'Public') {
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
    dnsSettings: {
      domainNameLabel: dnsLabelForPublicLoadBalancer
    }
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2023-04-01' = {
  name: lbName
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: frontEndIpConfigName
        properties: {
          publicIPAddress: (exposure == 'Public') ? publicIpAddress : null
          subnet: (exposure == 'Internal') ? subnet : null
        }
      }
    ]
    backendAddressPools: [
      {
        name: lbPoolName
      }
    ]
    loadBalancingRules: [
      {
        name: 'ssh'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 2222
          backendPort: 2222
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'semp'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 8080
          backendPort: 8080
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'semptls'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 1943
          backendPort: 1943
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'smf'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 55555
          backendPort: 55555
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'smf-compressed'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 55003
          backendPort: 55003
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'smftls'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 55443
          backendPort: 55443
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'webservices'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 8008
          backendPort: 8008
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'webtls'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 1443
          backendPort: 1443
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'amqp'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 5672
          backendPort: 5672
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'mqtt'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 1883
          backendPort: 1883
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'mqttweb'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 8000
          backendPort: 8000
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
      {
        name: 'rest'
        properties: {
          frontendIPConfiguration: {
            id: frontEndIpConfigId
          }
          backendAddressPool: {
            id: backendPoolId
          }
          protocol: 'Tcp'
          frontendPort: 9000
          backendPort: 9000
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          probe: {
            id: healthProbeId
          }
        }
      }
    ]
    probes: [
      {
        name: lbProbeName
        properties: {
          protocol: 'http'
          port: 5550
          intervalInSeconds: 5
          numberOfProbes: 2
          requestPath: '/health-check/guaranteed-active'
        }
      }
    ]
  }
}
