---
description: This template deploys an Application Gateway with WAF, end to end SSL and HTTP to HTTPS redirect on the IIS servers.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: application-gateway-2vms-iis-ssl
languages:
- json
---
# App Gateway with WAF, SSL, IIS and HTTPS redirection

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-2vms-iis-ssl/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-2vms-iis-ssl/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-2vms-iis-ssl/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-2vms-iis-ssl/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-2vms-iis-ssl/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/application-gateway-2vms-iis-ssl/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-2vms-iis-ssl%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-2vms-iis-ssl%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Fapplication-gateway-2vms-iis-ssl%2Fazuredeploy.json)

This template deploys an Application Gateway with WAF, end to end SSL and HTTP to HTTPS redirect on the IIS servers. It deploys two IIS servers into a new VNet. The certificates for the front end and back end connections can be different, to demonstrate the use of a public CA externally and an internal CA internally. HTTP to HTTPS redirection is currently not available on the Application Gateway, so in this template is achieved by using the URL Rewrite module in IIS. This will redirect all HTTP traffic back out to the HTTPS endpoint on the Application Gateway.

The following resources are deployed as part of the solution:

+ **Virtual Network**: A virtual network with two subnets, AppGatewaySubnet and WebSubnet.
+ **Application Gateway**: Application Gateway with WAF, size Medium by default and an instance count of 2 by default. The Application Gateway will have a public IP and will route connections to the internal addresses of two backend IIS servers on 80 and 443 with session persistence disabled.
+ **Two Windows Servers**: Two Windows 2022 (by default) servers running IIS. These servers will have a public IP and will be using managed disks. Default size is Standard_D2as_v5.

## Prerequisites

You will need certificates for this to successfully deploy. These can be valid certificates, or self-signed certificates (for demo and testing purposes). Specifically, you will need the following certs:

+ **Front End Certificate**: This is the certificate that will terminate SSL on the Application Gateway for traffic coming from the internet. This will need to be in .pfx format, and will need to be encoded in base-64 in order to include in the template deployment.
+ **Back End Certificate**: This is the certificate that will be installed on the IIS servers to encrypt traffic between the Application Gateway and the IIS servers. This could be the same as the front end certificate or could be a different certificate. This will need to be in .pfx format, and will need to be encoded in base-64 in order to include in the template deployment.
+ **Back End Public Key**: This is the public key from the back end certificate that will be used by the Application Gateway to whitelist the back end servers. This will need to be in .cer format, and will need to be encoded in base-64 in order to include in the template deployment.

If you have existing certs, you can jump down to the "Encode the certs" section below to base-64 encode them.

### Create self-signed certs

Follow the steps below to create self-signed certificates to use for this template. Note that you will get warnings in your browser when using these certificates as they are unable to be validated, but this will demonstrate the capabilities of using end-to-end SSL on Application Gateway.

Run the following PowerShell commands to create the self-signed certificates. Replace with the appropriate paths, DNS names and passwords as necessary.

**Front end certificate**

```
Get-ChildItem -Path $(New-SelfSignedCertificate -dnsname frontend.frontend).pspath | Export-PfxCertificate -FilePath "C:\frontend.pfx" -Password $(ConvertTo-SecureString -String "Password1234" -Force -AsPlainText)
```

**Back end certificate**

```
$cert = Get-ChildItem -Path $(New-SelfSignedCertificate -dnsname backend.backend).pspath
Export-PfxCertificate -Cert $cert -FilePath "C:\backend.pfx" -Password $(ConvertTo-SecureString -String "Password1234" -Force -AsPlainText)
```

**Back end public key**

```
Export-Certificate -Cert $cert -FilePath "C:\backend-public.cer"
```

### Encode the certs
In order to use the certificates in the template, they need to be base-64 encoded. The following commands will dump the encoded certs to text files, which you can copy the content to use in the template. Update the paths as necessary.

```
[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\frontend.pfx")) > "C:\frontend.txt"
[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\backend.pfx")) > "C:\backend.txt"
[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\backend-public.cer")) > "C:\backend-public.txt"
```

## Deployment steps

Click the "deploy to Azure" button at the beginning of this document.

## Connecting

The web page can be accessed by getting the IP or FQDN of the Application Gateway and viewing it in your browser of choice. Connection attemps via HTTP will be redirected to HTTPS. When connected you should see the default page showing which server you are connected to. Refreshing the page will send you to the other server.

Tags: `Application Gateway, IIS, SSL, Windows, DSC Extension`

`Tags: Microsoft.Compute/availabilitySets, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, extensions, DSC, Microsoft.Network/applicationGateways`
