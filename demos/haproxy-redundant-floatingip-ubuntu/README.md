---
description: This template creates a redundant haproxy setup with 2 Ubuntu VMs configured behind Azure load balancer with floating IP enabled. Each of the Ubuntu VMs run haproxy to load balance requests to other application VMs (running Apache in this case). Keepalived enables redundancy for the haproxy VMs by assigning the floating IP to the MASTER and blocking the load-balancer probe on the BACKUP. This template also deploys a Storage Account, Virtual Network, Public IP address, Network Interfaces.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: haproxy-redundant-floatingip-ubuntu
languages:
- bicep
- json
---
# Redundant haproxy with Azure load-balancer and floating IP

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/haproxy-redundant-floatingip-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/haproxy-redundant-floatingip-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/haproxy-redundant-floatingip-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/haproxy-redundant-floatingip-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/haproxy-redundant-floatingip-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/haproxy-redundant-floatingip-ubuntu/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/demos/haproxy-redundant-floatingip-ubuntu/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fhaproxy-redundant-floatingip-ubuntu%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fhaproxy-redundant-floatingip-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fhaproxy-redundant-floatingip-ubuntu%2Fazuredeploy.json)

This template creates 2 ubuntu (haproxy-lb) VMs under an *Azure load-balancer* (Azure-LB) configured with *floating IP* enabled. It also creates 2 additional Ubuntu (application) VMs running Apache (default configuration) for a proof-of-concept.

It uses *CustomScript Extension* to configure haproxy-lb VMs with haproxy/keepalived, and application VMs with apache2. The end-state configuration ensures only one of the haproxy-lb VMs is active and configured with the VIP (public IP) address.

It also deploys a Storage Account, Virtual Network, Public IP address, Availability Sets and Network Interfaces as required.

This template uses the resource loops capability to create network interfaces, virtual machines and extensions

### Notes
* Topology: Azure-LB -> haproxy-lb VMs (2) -> application VMs (2)
* Azure-LB
  * Azure-LB is configured with *enableFloatingIP* set to true in *loadBalancingRules*.
    * In this configuration, Azure-LB does not perform DNAT from public IP (VIP) to private IP address of the pool members. Instead, packets reach the pool member with the same destination IP set by the client.
  * Public IP **should** be configured on a network adapter of the pool member VMs to receive/respond to the requests.
* Haproxy-lb VMs
  * Public IP associated with Azure-LB is assigned to *only* one of the haproxy-lb VMs (MASTER as determined by keepalived).
  * Azure-LB probe on the other haproxy-lb VM (BACKUP) is explicitly disabled using a firewall(iptables) rule to block the LB probe port.
  * When a haproxy-lb VM status changes to MASTER, firewall rule(s) to block LB probe port is removed.
  * Custom keepalived verify and notify scripts are deployed to enable/disable probes as described above.
  * All configuration files are created as part of *CustomScript Extension*
* Application VMs
  * Apache webserver is deployed as part of *CustomScript Extension*. No changes are done to default configuration.
  * This is only a proof-of-concept. The functionality of application VMs can be modified per requirement. Corresponding changes need to be done to *variables* section of the template.

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Compute/availabilitySets, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/loadBalancers, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScript`
