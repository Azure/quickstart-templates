---
description: This template deploys Anbox Cloud on an Ubuntu VM. Completing the installation of Anbox Cloud requires user interaction following the deployment; please consult the README for instructions. The template supports both launching of a VM from an Ubuntu Pro image and association of an Ubuntu Pro token with a VM launched from a non-Pro image. The former is the default behaviour; users seeking to attach a token to a VM launched from a non-Pro image must override the default arguments for the ubuntuImageOffer, ubuntuImageSKU, and ubuntuProToken parameters. The template is also parametric in the VM size and disk sizes. Non-default argument values for these parameters must comply with https&#58;//anbox-cloud.io/docs/reference/requirements#anbox-cloud-appliance-4.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: anbox
languages:
- bicep
- json
---
# Deploy Anbox Cloud

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/canonical/anbox/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/canonical/anbox/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/canonical/anbox/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/canonical/anbox/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/canonical/anbox/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/canonical/anbox/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/canonical/anbox/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fcanonical%2Fanbox%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fcanonical%2Fanbox%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fcanonical%2Fanbox%2Fazuredeploy.json)

This template deploys [Anbox Cloud](https://anbox-cloud.io/) on an Ubuntu VM. Completing the installation of Anbox Cloud requires user interaction following the deployment; please follow the instructions in the **Deployment steps** section below when deploying.

## Prerequisites

The template supports both launching of a VM from an Ubuntu Pro image and association of an Ubuntu Pro token with a VM launched from a non-Pro image. Users seeking the latter behaviour must [obtain a Pro token](https://canonical-ubuntu-pro-client.readthedocs-hosted.com/en/latest/howtoguides/get_token_and_attach/#get-an-ubuntu-pro-token) before proceeding with deployment.

The template is also parametric in the public SSH key of the VM administrator. To create a new key pair for this purpose, please follow [these instructions](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys#create-an-ssh-key-pair).

## Deployment steps

To begin the deployment, either click the **Deploy to Azure** button at the beginning of this document or follow the instructions for command-line deployment using the scripts in the root of this repository. You will be prompted for the VM administrator's username and public SSH key (see the **Prerequisites** section above for more information regarding the latter).

By default, the template will launch a VM from an Ubuntu Pro image. If you would rather associate an Ubuntu Pro token with a VM launched from a non-Pro image, then you will need to override the default arguments for the template's `ubuntuImageOffer`, `ubuntuImageSKU` and `ubuntuProToken` parameters. Note that any Pro token supplied as an argument will be [ignored by cloud-init](https://cloudinit.readthedocs.io/en/latest/reference/modules.html#ubuntu-pro) if the arguments provided for the `ubuntuImageOffer` and `ubuntuImageSKU` parameters correspond to a Pro image.

Once the deployment is complete, follow [these instructions](https://anbox-cloud.io/docs/tutorial/installing-appliance#initialise-the-appliance-6) to initialize the Anbox Cloud Appliance and register your Ubuntu SSO account with the Appliance. The machine (VM) IP address referenced in the instructions is available as the `virtualMachinePublicIPAddress` output from the template. Note that the SSH command presented to you in your browser during Appliance initialization reflects certain assumptions regarding the location of the VM administrator's private SSH key. If you would like to point the `ssh` command to a private key at a particular location in your filesystem, the `sshCommand` output from the template provides an example of how to do so (replace `$PATH_TO_ADMINISTRATOR_PRIVATE_SSH_KEY` with the filesystem location).

### Advanced configuration

The template allows users to attach a dedicated data disk for LXD to the VM and to expose both the Anbox Management Service and services running on Anbox containers to the public internet.

#### Dedicated disk for LXD

By default, `anbox-cloud-appliance init` (see the linked instructions in the **Deployment steps** section above) will deploy the LXD storage pool to a dedicated data disk. Users wishing to instead host the LXD storage pool on the operating system disk can override the default argument for the template's `addDedicatedDataDiskForLXD` parameter. Note that when a dedicated data disk is attached to the VM, `anbox-cloud-appliance init` will automatically detect the disk's presence and deploy the LXD storage pool to the disk, so the user need not override any of the default answers to the questions that `anbox-cloud-appliance init` presents.

#### Exposing Anbox services to the public internet

The template includes two parameters that allow the user to expose Anbox services running on the VM to the public internet. The first parameter, `exposeAnboxManagementService`, exposes the Anbox Management Service on port 8444. The second parameter, `exposeAnboxContainerServices`, exposes Anbox container services on the port range 10000-11000. When the default arguments for these parameters are not overriden, the Anbox Management Service and any container services will only be accessible from the VM.

`Tags: Anbox, Azure4Student, Microsoft.Compute/virtualMachines, Microsoft.Network/networkInterfaces, Microsoft.Network/networkSecurityGroups, Microsoft.Network/publicIPAddresses, Microsoft.Network/virtualNetworks, Microsoft.Network/virtualNetworks/subnets, Ubuntu`
