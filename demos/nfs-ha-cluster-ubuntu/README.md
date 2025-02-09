---
description: Deploys a highly availe 2-VM NFS cluster based on DRBD, Pacemaker and Corosync with Ubuntu.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: nfs-ha-cluster-ubuntu
languages:
- json
---
# Highly available NFS cluster in Ubuntu

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/nfs-ha-cluster-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/nfs-ha-cluster-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/nfs-ha-cluster-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/nfs-ha-cluster-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/nfs-ha-cluster-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/nfs-ha-cluster-ubuntu/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fnfs-ha-cluster-ubuntu%2Fazuredeploy.json)
[![Deploy to Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fnfs-ha-cluster-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fnfs-ha-cluster-ubuntu%2Fazuredeploy.json)

This template allows you to create a highly available NFS cluster on Azure with 2 Ubuntu VMs. The following diagram shows the architecture of the deployed cluster.

![cluster_diagram](images/NFS-HA-Arch.png "Diagram of deployed cluster")

## Usage

### Template Parameters

There are many parameters this template requires. Some notable and important ones are as follows:

- `subnetId`: This is where the highly available NFS cluster will be deployed. You need to give the Azure resource ID of an already existing Azure subnet where the cluster should be deployed.
- `node0IPAddr` and `node1IPAddr`: The 2 VMs will have to be assigned static IP addresses for the high availability configuration in the deployed VMs. You need to specify those statically assigned IP addresses (that belong to the subnet specified above) as these parameters.
- `lbFrontEndIpAddr`: The NFS service on the cluster will be accessed through this IP address, so you need to specify an IP address here (that belongs to the subnet specified above).
- `nfsClientsIPRange`: The NFS-exported directory (currently fixed to `{lbFrontEndIpAddr}:/drbd/data`) will be available only to the NFS clients from this IP address range (e.g., `10.0.0.0/24`), so you need to provide one here.
- `dataDiskCountPerVM`: The number of data disks in each VM. If this is bigger than one, all the data disks will pool into a RAID-0 (striped) disk array.

Other template parameters are typical VM deployment ones.

### Validating the Deployed Cluster

To test the deployed cluster, you'll need an SSH-accessible VM on the subnet that corresponds to the `nfsClientsIPRange` IP range. Note that the 2 VMs in the deployed NFS-HA cluster are not assigned any public IP addresses and the load balancer is strictly internal, so the 2 VMs are not SSH-accessible from anywhere else other than VMs on the same subnet. That's why you'll need another VM on the subnet if you'd like to SSH into either of the 2 deployed VMs. Note that you don't need to be able to SSH into any of the 2 deployed VMs to test the NFS functionality. If the `subnetId`'s IP range is the same (or a subnet of) `nfsClientsIPRange`, you should be able to SSH into the 2 deployed VMs as well, but otherwise, you can only test the NFS functionality from a VM on the `nfsClientsIPRange` IP range. To test the NFS functionality, you should be able to see the exported NFS directory on such a test VM by issuing `showmount -e {lbFrontEndIpAddr}` and then mount it using `sudo mkdir -p /mnt/nfs; sudo mount -t nfs {lbFrontEndIpAddr}:/drbd/data /mnt/nfs`. Don't forget to `sudo umount /mnt/nfs` before finishing testing.

### Using the Templates in Your Own Templates

If you need or want to create a highly available NFS cluster in your own templates, you can do so by deploying the templates in this directory. However, you can just copy the `nested/nfs-ha.json` and the `nested/nfs-ha-vm.json` template files only to your own nested templates directory and deployed the `nested/nfs-ha.json` directly, instead of copying and deployging the `azuredeploy.json` in this directory. That's because the `azuredeploy.json` in this directory is just a shell mainly for the Azure quickstart repo's CI (that requires a subnet to be provided, so one needs to be created in CI using the `azuredeploy.json` and `nested/nfs-ha-vnet-default.json`) In your own templates, a subnet should be created in advance and its resource ID should be provided as a template parameter. See the [Moodle-on-Azure](https://github.com/Azure/Moodle) [template](https://github.com/Azure/Moodle/blob/master/azuredeploy.json) (search for `nfsHaTemplate` deployment).

### Deploying the whole Infrastrucuture at once

In order to deploy the whole nfs server infrastructure, you will need to deploy the
solutions on the ```prereqs``` folder, get its outputs and use as inputs in the
```nfs-ha.json``` file, that is inside the ```nested``` folder. In order to help in
this process, we created a script called ```deploy_everything.sh``` inside the
```scripts``` folder that does this job. In order to run this script, inside
the ```scripts``` folder, run:

``` shell
chmod +x deploy_everything.sh
./deploy_everything.sh <name_of_the_resource_group_to_deploy>
```

## Brief Explanation

As illustrated in the cluster diagram above, the deployed HA-NFS cluster consists of 2 Ubuntu VMs and one Azure load balancer (internal). Each cluster is configured with the following software stack:

- Usual NFS server components (`nfs-kernel-server` on Ubuntu)
- [DRBD](https://docs.linbit.com/) for disk replication between 2 VMs
- [Corosync](https://github.com/corosync/corosync) and [Pacemaker](https://wiki.clusterlabs.org/wiki/Pacemaker) for clustering engine and cluster resource management

The usual highly available clustering on non-cloud environment is achieved by a fixed secondary IP address that is attached to the master node and fails over to the secondary node. However, an IP address fail-over is not straightforward in Azure (and probably other cloud environments as well). Therefore, we use a load balancer (an internal one with a private front-end IP address on the same subnet) to route traffic only to the master node. For that purpose, the probe responder runs only on the master node (on port 61000 as `/bin/nc` for TCP probing) and it also fails over to the secondary with other core services (DRBD, NFS and etc).

Because we have to use a load balancer for the highly available front-end IP address, we need to make the various NFS-related service ports (e.g., rpdbind, statd, lockd, ...) statically assigned on each VM. In our templates, you'll see that those ports are statically bound to 2000-2005 and the load balancer is configured for the ports as such.

## TO-DO

Currently, [STONITH](https://en.wikipedia.org/wiki/STONITH) is disabled, so thoeretically [split-brain](https://en.wikipedia.org/wiki/Split-brain_(computing)) might occur. Any PRs addressing this issue are very welcome.

We also need to conduct some load testing for a deployed NFS-HA cluster with high workload. We'll perform a load testing study based on the [Moodle-on-Azure project](https://github.com/Azure/Moodle/tree/master/loadtest), which is the motivation for this NFS-HA templated solution.

## Acknowledgements

Matt Kereczman (@kermat on GitHub) from [LINBIT](https://www.linbit.com/) (the force behind DRBD, which LINBIT claims is the de facto open standard for High Aavailability software for enterprise and cloud computing) greatly helped with the Pacemaker configuration for NFS fail-over and the Azure LB-based highly available front-end IP address. Thanks to Matt's help, I think this template can be made possible at least a few more weeks earlier than expected.

This templated solution for highly available NFS was created mostly for the [Moodle-on-Azure](https://github.com/Azure/Moodle). In the process, we came to realize that this might be useful for other Azure Linux customers as well on many other occasions. Therefore, we made the templates as generic as possible for Azure quickstart templates repo publication.

`Tags: Microsoft.Resources/deployments, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, extensions, CustomScript, Microsoft.Compute/availabilitySets, Microsoft.Network/loadBalancers, Microsoft.Network/virtualNetworks`
