# Simple Linux Virtual Machine on Azure Edge Zones

The purpose of this ARM Template is **simple Linux Virtual Machine on Edge Zones** inserting a few parameters.

## The Template

Don't let the size of the template scare you. The structure is very intuitive and once that you get the gist of it, you will see how much easier your life will be deploying resources to Azure.

These are the parameters on the template, most of them already have values inserted, the ones that you need to inform are: **adminUsername**, **adminPassword** and **resourceGroup**.

Parameter         | Suggested value     | Description
:--------------- | :-------------      |:---------------------
**vmName** | The name of your Virtual Machine | The name of you Virtual Machine.
**VmSize** | Standard_D2_v3 | The size of the VM.
**adminUsername** | adminusername | Usernames can be a maximum of 20 characters and cannot end in a period (".").
**adminPassword** | Complex Password | Password requirements between 12 to 72 characters and have lower and upper characters, a digit and a special character (Regex match [\W_])
**Location** | The default location | Select the geographic location for your resource group.
**edgeZone** | The Edge Zone name| Select the edge zone for your resources to be deployed. 
**ubuntuOSVersion** | 18.04-LTS | The Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.
**authenticationType** | password | Type of authentication to use on the Virtual Machine.
**dnsLabelPrefix** | dns-vmName | Unique DNS Name for the Public IP used to access the Virtual Machine
**virtualNetworkName** | vNet | Name of the VNET
**subnetName** | subnet | Name of the subnet in the virtual network
**networkSecurityGroupName** | SecGroupNet | Name of the Network Security Group
**Resource Group**| myResourceGroup |  That is the Resource Group that you need to deploy your resources.

## Deployment

There are a few ways to deploy this template.
You can use [PowerShell](https://docs.microsoft.com/azure/azure-resource-manager/resource-group-template-deploy), [Azure CLI](https://docs.microsoft.com/azure/azure-resource-manager/resource-group-template-deploy-cli), [Azure Portal](https://docs.microsoft.com/azure/azure-resource-manager/resource-group-template-deploy-portal) or your favorite SDK.

For Azure CLI I'm using the Visual Code with Azure CLI extensions. If you would like you can find more information [here](https://code.visualstudio.com/docs/azure/extensions). But bare in mind that you don't need to use the Visual Code app, you can stick with the always present **Command Line** on Windows or the Linux **bash terminal**.

### Using Azure CLI with Visual Code

In the terminal window type: **az login**

![Screen](./images/azlogin.png)

You will be redirected to the Azure Portal in your web browser where you can insert your credentials and log in.

After logging in, you will see your credentials on the terminal.

To set the right subscription, type following command:

#### az account set --subscription "your subscription id"

![Screen](./images/azsetsub.png)

### Resource Group

Now you need a Resource Group for our deployment. If you haven't already created a Resource Group, you can do it now. If you are new to Azure and wonder what is a Resource Group? Bare with me! A Resource Group is a container that holds related resources for an Azure solution. The resource group includes those resources that you want to manage as a group. Simply saying: it's like a folder that contains files. Simple as that.

To create a Resource Group, you need a name and a location for your Resource Group.

For a list of locations, type: **az account list-locations**

To create the Resource group, type the command:

#### az group create --name "resource-group" --location "your location"

![Screen](./images/azgroup.png)

Super simple, right? Now that we have our **Resource Group** created, let's deploy the **Simple Linux Virtual Machine** using the az cli.

#### az group deployment create --name "name of your deployment" --resource-group "resource-group" --template-file "./azuredeploy.json"

![Screen](./images/azdeploy.png)

Insert the values for the parameters.
As you can see, it's running.

Go grab a cup of coffee, have some fresh air. Before you come back you will have your  **Virtual Machine**.

And there we go, your deployment has Succeeded:

![Screen](./images/azdeploy2.png)

Let's check the resource in the [Azure Portal](https://portal.azure.com).

On the portal, navigate to Resource Groups. On this blade, you can see the Resource Group we've created.

![Screen](./images/azdeployportal.png)

Click on the Resource Group to expand and show the **Resources**:

- Network security group
- Disk
- Network interface
- Public IP address
- Virtual network
- Virtual machine

Click on the Virtual Machine and then click in **connect**.

Where you have **Login using VM Local account** copy the ssh command and open your terminal.

![Screen](./images/azdeployportal3.png)

Paste the command and press **Enter**.  

Insert the password you've created.  

![Screen](./images/azssh.png)

And Voilà, there you have a brandy new Ubuntu Virtual Machine.

![Screen](./images/azubuntu.png)

Most important, don't forget to have fun!

### Using the Portal

Using your favorite web browser Navigate to the Portal, in All Services look for **Templates**, you may want to add this service to favorites.

Click on **Add** to add your template:

On General, type the name and the description for your template, and click on [OK].

![Screen](./images/aztemplate.png)

On ARM Template, replace the contents of the template with your template, and click on [OK].

![Screen](./images/aztemplate2.png)

Click on the refresh button and there is your template:

![Screen](./images/aztemplate3.png)

Open the template and click in [Deploy]

On the screen Custom Deployment, insert the information that you must be already familiar with.

Select [I agree] and click on [Purchase].

As you can see, it's deploying.

After a couple of minutes, voilà, you have your Virtual Machine deployed.

![Screen](./images/azportaldeploy3.png)

Go to the Resource. Repeat the test that you have done before.

**p.s.: It's pretty easy to create resources on Azure, right? But if you are the sort of IT guy that always loves automation, here is the surprise. Just click on the button below and it will automatically deploy simple Linux Virtual Machine through the  Azure Portal.**

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-simple-linux%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>

#### Important disclaimer: Azure charges you for the resources you are using, and you don't want to use all your credits at once, right? So, don't forget to stop the Virtual Machine at the portal or even delete the Resource Group you have created to avoid unnecessary charges

### How to shutdown your resources

#### Using the portal

On the portal, open your Resource Group, you can either stop the Virtual Machine clicking on [Stop] or delete the Virtual Machine clicking on [Delete].

![Screen](./images/off1.png)

You can also delete the Resource Group. Click on the Resource Group and then in [Delete].

![Screen](./images/off2.png)

Just refresh your screen and you are good to go.
