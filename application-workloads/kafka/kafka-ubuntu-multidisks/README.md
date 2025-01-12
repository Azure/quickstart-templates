---
description: This template creates Kafka streaming replication from one zookeeper to one or more brokers each configured with multiple striped data disks. The database servers are deployed into a private subnet with an optional externally accessible jumpbox.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: kafka-ubuntu-multidisks
languages:
- json
---
# Kafka on Ubuntu VMs

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kafka/kafka-ubuntu-multidisks/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kafka/kafka-ubuntu-multidisks/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kafka/kafka-ubuntu-multidisks/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kafka/kafka-ubuntu-multidisks/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kafka/kafka-ubuntu-multidisks/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/kafka/kafka-ubuntu-multidisks/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fkafka%2Fkafka-ubuntu-multidisks%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fkafka%2Fkafka-ubuntu-multidisks%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fkafka%2Fkafka-ubuntu-multidisks%2Fazuredeploy.json)

Apache Kafka is publish-subscribe messaging rethought as a distributed commit log.

Kafka is designed to allow a single cluster to serve as the central data backbone for a large organization. It can be elastically and transparently expanded without downtime. Data streams are partitioned and spread over a cluster of machines to allow data streams larger than the capability of any single machine and to allow clusters of co-ordinated consumers

Kafka has a modern cluster-centric design that offers strong durability and fault-tolerance guarantees.

This template deploys a Kafka cluster on the Ubuntu virtual machines. This template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.
The template also creates 1 publicly accessible VM acting as a "jumpbox" and allowing to ssh into the Kafka nodes for diagnostics or troubleshooting purposes.
The template creates the following deployment resources:
* Virtual Network with two subnets: "dmz 10.0.0.0/24" for the jumpbox VM, "zookeeper 10.0.1.0/24" and "data 10.0.2.0/24" for the Kafka Broker VMs
* Storage accounts to store VM data disks
* Public IP address for accessing the jumpbox via ssh
* Network interface card for each VM
* Multiple remotely-hosted Custom Script Extensions to strip the data disks and to install and configure Kafka services

Assuming your domainName parameter was "kafkajumpbox" and region was "West US"
* Kafka servers will be deployed at IP address prefix in the subnet: 10.0.2.10,10.0.2.11,10.0.2.12, etc.
* Zookeeper servers will be deployed in the other IP addresses: 10.0.1.10, 10.0.1.11, 10.0.1.12, etc.
* From your computer, SSH into the jumpbox `ssh kafkajumpbox.westus.cloudapp.azure.com`
* From the jumpbox, SSH into the Kafka server `ssh 10.0.2.4`

The following table outlines the deployment topology characteristics for each supported t-shirt size:

 |T-Shirt Size|Database VM Size|CPU Cores|Memory| Data Disks|# of Brokers|# of Zookeepers|# of Storage Accounts|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
 |Small | Standard_A1 | 1 | 1.75 GB | 2x1023 GB | 3 | 1 | 1
 |Medium | Standard_A3 | 4 | 7 GB | 8x1023 GB | 5 | 3 | 2
 |Large | Standard_A4 | 8 | 14 GB | 16x1023 GB | 5 | 3 | 3
 |XLarge | Standard_A7 | 8 | 56 GB | 16x1023 GB | 8 | 5 | 4

How to Run the scripts
----------------------

You can use the Deploy to Azure button or use the below methor with powershell

Creating a new deployment with powershell:

Remember to set your Username, Password and Unique Storage Account name in azuredeploy-parameters.json

Create a resource group:

    PS C:\Users\azureuser1> New-AzureResourceGroup -Name "AZKFRKAFKAEA3" -Location 'EastAsia'

Start deployment

    PS C:\Users\azureuser1> New-AzureResourceGroupDeployment -Name AZKFRGKAFKAV2DEP1 -ResourceGroupName "AZKFRGKAFKAEA3" -TemplateFile C:\gitsrc\azure-quickstart-templates\kafka-ubuntu-multidisks\azuredeploy.json -TemplateParameterFile C:\gitsrc\azure-quickstart-templates\kafka-ubuntu-multidisks\azuredeploy-parameters.json -Verbose

    On successful deployment results will be like this

	DeploymentName    : AZKFRGSPARKV2DEP1
	ResourceGroupName : AZKFRGSPARKEA1
	ProvisioningState : Succeeded
	Timestamp         : 4/28/2015 9:11:19 PM
	Mode              : Incremental
	TemplateLink      :
	Parameters        :

	    Name             Type                       Value
	    ===============  =========================  ==========
	    region           String                     West US
	    storageAccountNamePrefix  String                     cgnarmstrkafkav4
	    domainName       String                     kafkacgnarmv4
	    adminUsername    String                     adminuser
	    adminPassword    SecureString
	    tshirtSize       String                     Small
	    jumpbox          String                     Enabled
	    virtualNetworkName  String                     vnet

Check Deployment
----------------

To access the individual Kafka nodes, you need to use the publicly accessible jumpbox VM and ssh from it into the VM instances running Kafka.

To get started connect to the public ip of Jumpbox with username and password provided during deployment.
From the jumpbox connect to any of the Kafka brokers eg: SSH into the Kafka server `ssh 10.0.2.4` ,`ssh 10.0.2.5`, etc.
Run the command ps-ef|grep kafka to check that kafka process is running ok.
You can run the kafka commands like this:

	cd /usr/local/kafka/kafka_2.10-0.8.2.1/

	bin/kafka-topics.sh --create --zookeeper 10.0.1.10:2181  --replication-factor 2 --partitions 1 --topic my-replicated-topic1

	bin/kafka-topics.sh --describe --zookeeper 10.0.1.10:2181  --topic my-replicated-topic1

Topology
--------

The deployment topology is comprised of Kafka Brokers and Zookeeper nodes running in the cluster mode.
Kafka version 0.8.2.1 is the default version and can be changed to any pre-built binaries avaiable on Kafka repo.
A static IP address will be assigned to each Kafka node (by default, the first node will be assigned the private IP of 10.0.2.10, the second node - 10.0.2.11, and so on)
A static IP address will be assigned to each Zookeeper node(by default, the first node will be assigned the private IP of 10.0.1.10, the second node - 10.0.1.11, and so on)

To check deployment errors go to the new azure portal and look under Resource Group -> Last deployment -> Check Operation Details

## Known Issues and Limitations

- Health monitoring of the Kafka instances is not currently enabled
- SSH key is not yet implemented and the template currently takes a password for the admin user

`Tags: Microsoft.Resources/deployments, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, CustomScript, Microsoft.Network/publicIPAddresses, Microsoft.Storage/storageAccounts, Microsoft.Network/virtualNetworks, Microsoft.Compute/availabilitySets`
