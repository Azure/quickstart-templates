---
description: The secure key release (SKR) feature in Azure Key Vault Premium SKU and Managed-HSM is a way to control the release of keys to trusted execution environments (TEE), such as an Azure Confidential Virtual Machine, which is a special type of virtual machine designed for high-security scenarios. Key Vault's policy-based approach to releasing keys enforces verification of trusted execution environments, ensuring that only authorized and compliant virtual machines can access the keys.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: confidential-vm-linux-keyvault-secure-key-release
languages:
- json
- bicep
---
# Deploy a Linux CVM, configured for Secure Key Release

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/confidential-vm-linux-keyvault-secure-key-release/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/confidential-vm-linux-keyvault-secure-key-release/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/confidential-vm-linux-keyvault-secure-key-release/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/confidential-vm-linux-keyvault-secure-key-release/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/confidential-vm-linux-keyvault-secure-key-release/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/confidential-vm-linux-keyvault-secure-key-release/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/confidential-vm-linux-keyvault-secure-key-release/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fconfidential-vm-linux-keyvault-secure-key-release%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fconfidential-vm-linux-keyvault-secure-key-release%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fconfidential-vm-linux-keyvault-secure-key-release%2Fazuredeploy.json)

## Deploy a confidential Linux virtual machine that can perform the Secure Key Release operation on an Azure Key Vault Premium, HSM-backed, key

The secure key release (SKR) feature in Azure Key Vault Premium SKU and Managed-HSM is a way to control the release of keys to trusted execution environments (TEE), such as an Azure Confidential Virtual Machine, which is a special type of virtual machine designed for high-security scenarios. Key Vault's policy-based approach to releasing keys enforces verification of trusted execution environments, ensuring that only authorized and compliant virtual machines can access the keys.

## Tasks performed by this template

This template performs the following tasks:

1. Deploys a confidential Linux virtual machine.
    * Installs the [Linux Azure Guest Attestation library](https://packages.microsoft.com/repos/azurecore/pool/main/a/azguestattestation1/) and its dependencies.
    * Clones the [Azure Guest Attestation repository](https://github.com/Azure/confidential-computing-cvm-guest-attestation/), which includes the `AttestationClient` binary.
1. Assigns a managed identity to the confidential virtual machine.
    * This can be a system-assigned managed identity or a user-assigned managed identity, which allows multiple resources to be added to the identity.
1. Sets a Key Vault access policy to grant the managed identity the "release" key permission.
    * This allows the confidential virtual machine to access the Key Vault and perform the release operation.
1. Creates a Key Vault key that is marked as exportable and has an associated release policy.
    * This will enforce that the Key Vault key can only accessed by the confidential virtual machine.

## Performing the key release operation

To perform the release, send an HTTP request to the Key Vault from the confidential virtual machine. This request must include the Confidential VM's attested platform report in the request body. The attested platform report is used to verify the trustworthiness of the state of the Trusted Execution Environment-enabled platform, such as the Confidential VM. The [Microsoft Azure Attestation service](https://learn.microsoft.com/en-us/azure/attestation/overview) can be used to create the attested platform report and include it in the request.

To receive an attested platform report, you can use any scripting or programming language to call the `AttestationClient` binary. Since the virtual machine we deployed has managed identity enabled, we can get an Azure Active Directory (AAD) issued access token for Key Vault from the [instance metadata service](https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service?tabs=windows) (IMDS). The deployment template will ensure that the virtual machine's managed identity has been given the `release` permission in Azure Key Vault.

The AAD token will be used to access the Azure Key Vault data plane. To obtain the token, you can make a REST endpoint call to the IMDS inside the virtual machine. This will give you an access token for a specific Azure resource, in this case, the Key Vault. Once you have the attested platform report and the AAD token, you can set the attested platform report as the body payload and the AAD token in the authorization header of the HTTP request to perform the key release operation.

> The `AttestationClient` binary can be found in `/confidential-computing-cvm-guest-attestation/cvm-platform-checker-exe/Linux/cvm_linux_attestation_client.zip`, by unzipping the file.

```powershell
#Requires -Version 7
#Requires -RunAsAdministrator
#Requires -PSEdition Core

<#
.SYNOPSIS
    Perform Secure Key Release operation in Azure Key Vault, provided this script is running inside an Azure Confidential Virtual Machine.
.DESCRIPTION
    Perform Secure Key Release operation in Azure Key Vault, provided this script is running inside an Azure Confidential Virtual Machine.
     The release key operation is applicable to all key types. The target key must be marked exportable. This operation requires the keys/release permission.
.PARAMETER -AttestationTenant
    Provide the attestation instance base URI, for example https://mytenant.attest.azure.net.
.PARAMETER -VaultBaseUrl
    Provide the vault name, for example https://myvault.vault.azure.net.
.PARAMETER -KeyName
    Provide the name of the key to get.
.PARAMETER -KeyName
    Provide the version parameter to retrieve a specific version of a key.
.INPUTS
    None.
.OUTPUTS
    System.Management.Automation.PSObject
.EXAMPLE
    PS C:\> .\Invoke-SecureKeyRelease.ps1 -AttestationTenant "https://sharedweu.weu.attest.azure.net" -VaultBaseUrl "https://mykeyvault.vault.azure.net/" -KeyName "mykey" -KeyVersion "e473cd4c66224d16870bbe2eb4c58078"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]
    $AttestationTenant,
    [Parameter(Mandatory = $true)]
    [string]
    $VaultBaseUrl,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyName,
    [Parameter(Mandatory = $false)]
    [string]
    $KeyVersion
)
# Check if AttestationClient* exists.
$fileExists = Test-Path -Path "AttestationClient*"
if (!$fileExists) {
    throw "AttestationClient binary not found. Please download it from 'https://github.com/Azure/confidential-computing-cvm-guest-attestation'."
}

$cmd = $null
if ($isLinux) {
    $cmd = "sudo ./AttestationClient -a $attestationTenant -o token"
}
elseif ($isWindows) {
    $cmd = "./AttestationClientApp.exe -a $attestationTenant -o token"
}

$attestedPlatformReportJwt = Invoke-Expression -Command $cmd
if (!$attestedPlatformReportJwt.StartsWith("eyJ")) {
    throw "AttestationClient failed to get an attested platform report."
}

## Get access token from IMDS for Key Vault
$imdsUrl = 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net'
$kvTokenResponse = Invoke-WebRequest -Uri  $imdsUrl -Headers @{Metadata = "true" }
if ($kvTokenResponse.StatusCode -ne 200) {
    throw "Unable to get access token. Ensure Azure Managed Identity is enabled."
}
$kvAccessToken = ($kvTokenResponse.Content | ConvertFrom-Json).access_token

# Perform release key operation
if ([string]::IsNullOrEmpty($keyVersion)) {
    $kvReleaseKeyUrl = "{0}/keys/{1}/release?api-version=7.3" -f $vaultBaseUrl, $keyName
}
else {
    $kvReleaseKeyUrl = "{0}/keys/{1}/{2}/release?api-version=7.3" -f $vaultBaseUrl, $keyName, $keyVersion
}

$kvReleaseKeyHeaders = @{
    Authorization  = "Bearer $kvAccessToken"
    'Content-Type' = 'application/json'
}

$kvReleaseKeyBody = @{
    target = $attestedPlatformReportJwt
}

$kvReleaseKeyResponse = Invoke-WebRequest -Method POST -Uri $kvReleaseKeyUrl -Headers $kvReleaseKeyHeaders -Body ($kvReleaseKeyBody | ConvertTo-Json)
if ($kvReleaseKeyResponse.StatusCode -ne 200) {
    Write-Error -Message "Unable to perform release key operation."
    Write-Error -Message $kvReleaseKeyResponse.Content
}
else {
    $kvReleaseKeyResponse.Content | ConvertFrom-Json
}
```

### Key Release Response

The secure key release operation only returns a signed JSON Web Token (__JWT__) that contains a SON Object Signing and Encryption (JOSE) header header, a JSON Web Signature (JWS) payload and JWS signature. We can split the string by the `.` (dot) value and base64url decode the results.

> [base64url](https://www.rfc-editor.org/rfc/rfc4648#section-5) is a slightly modified version of the base64, which ensures that content is encoded (and decoded) using a URL and filename safe alphabet.

```json
{
    "value": "eyJhbGciOiJSU<omitted>JdfQ.eyJyZXF1ZXN0I<omitted>9fX0.Ri2pabThOfPKPm<omitted>3djA"
}
```

The JOSE header (JSON Object Signing and Encryption) contains a [X.509 certificate chain](https://www.rfc-editor.org/rfc/rfc7515#section-4.1.6), one of which corresponds to the key used to digitally sign the JWS. The `kid` indicates which key was used to sign the JSON Web Signature.

```json
{
  "alg": "RS256",
  "kid": "88EAC2DB6BE4E051B0E05AEAF6CB79E675296121",
  "x5t": "iOrC22vk4FGw4Frq9st55nUpYSE",
  "typ": "JWT",
  "x5t#S256": "BO7jbeU3BG0FEjetF8rSisRbkMfcdy0olhcnmYEwApA",
  "x5c": [
    "MIIIfDC...",
    "MIIF8zC...",
    "MIIDjjC..."
  ]
}
```

The key `release` response looks similar to the response that you get when invoking the `get` key operation. However, the `release` operation will also include the `hsm_key` property, amongst other things.

```json
{
    "request": {
        "api-version": "7.3",
        "enc": "CKM_RSA_AES_KEY_WRAP",
        "kid": "https://skr-kvq6srllol2jntw.vault.azure.net/keys/myskrkey"
    },
    "response": {
        "key": {
            "key": {
                "kid": "https://skr-kvq6srllol2jntw.vault.azure.net/keys/myskrkey/e473cd4c66224d16870bbe2eb4c58078",
                "kty": "RSA-HSM",
                "key_ops": [
                    "encrypt",
                    "decrypt"
                ],
                "n": "nwFQ8pXnQWPmjHDhNrjca0hzZ-fEgNboahlnu_kNBbM85CRBjovcnQPkP-UD_ILZ-KAcQopahYO4lTewBMKRoi547Ks2E6CSTr4FWYfyZXbGGUaxLW-_ziCeCubAXuPiiMUpbgLYVqX0ycvlH5lbbvSib8YoB4EANI7lyPFU6EUi25SxNcV8L5hK3Lx8NDQmPdKfaRldJIJU7IOO8hEZYpQ6leicDpjDvQBIHhYtZVZTd7bEhvsxqnrLK0yyoqh7K9QYJ9Ne7vwdWmRhgxnK47se79hZhqo2QqSBG004t6GjXoq1uLXrg71w57N5vVCVg64Z78theJFVeEdUlPvHkGLThViXkd9zsTpJx1m4beJovFgdD2YOKef-ACz2XRlb8KoOOc-hqfTB3uqi3i3oG2xmox6PyLV4_-wstNoQ0npJ3uhYbYlHq-6mw-d9fS48KutMfY23913zV6FQweil4I_RxTjWwElE8gpdSp01oyeo9UV-M7KHlTY-mFp5dcMdgcl4DTdOhTyntZqZS-KznkMOYJUijEJkVtElGru0NJo8yMbbTdsbdziH5NkIrdqEHX2u2130eQ3lB_NqT4hjErXwBe0N37UDeaJgaD5G-53jWJP1gwbuukE6oKpOnBl62e9NNS3HX0Ctu5Bte9ACii1EICZxjsyy01eXDxQJ20M",
                "e": "AQAB",
                "key_hsm": "eyJzY2hlbWFfdmVyc2lvbiI6IjEuMCIsImhlYWRlciI6eyJraWQiOiJUcG1FcGhlbWVyYWxFbmNyeXB0aW9uS2V5IiwiYWxnIjoiZGlyIiwiZW5jIjoiQ0tNX1JTQV9BRVNfS0VZX1dSQVAifSwiY2lwaGVydGV4dCI6IlJmdHh2cld0N2JXanQ5SFpoeUdtdGlzelhUXzlPRDRtWTJ0Vkc5N0dNSmlOWkVLcmZIX1ZiNkNUOEdPUXFfMEw5OTNqLUpwbklyZlN3Qk5WTTdlcmFQcU9tSFRCc19fMEIweS1XM0QzYjA0dDdHM3Z6cEk2Z2ZzMllOTTRoVURWWkFCWkE1dFJLa2M2NkNadzZQR194SFV2SlB6NHdSSmRNVFhvNXBvUGRWYVdabDdGb002TmFNcDhibXFfaGhobDFpeFlXYjhpTDNVTHVFdW9QM0JtNnVJMThmZ2ZQN1VMaDF0TUlFNEQ4REp6aGJnbDhYMjBoYUo2V0hxV090VFZXajN2U2FhUHFVdEpuQmpmUm1tQ200RHZiZlV1aGo0MVVweDQ3MVhwSXhKTVd5UTd1bklBT09DSUIzc09jdXBYUXNYZFJxbDh5ckNBS2ZuUTlXTHlFMk9aVlZmeEFocjc0WTdZSy1xMjhjZVF4LVc2ZEZQaEtvWnpZRUIzMjZKNk5Cd1I4RENEbEJPMEhjUGF0aUpqelZHOEY3YXNhTHZQRlcyUkk0aU4yNE1mR1R1OUdadjVMUmFXLUJsazZmNnR1Wlk1eTZaMEtUb2xOTVYxNlBFUXVCZzBiN1pDV29zMEVxMlh1azFra0wtLXpYZ2lkcTN3MGU3cGg2dWJTeTNaSUNZWjBTLTJHdlk3N3dkMXozamFBdHRhZU5qY0stcWRSYjVoSkpNSWdfQWQ3cXF0amVwM0IxTXlsblBqWG1kMWJLUEJUZWxwQ3FPaGZuQ2Z5eEh1NTRYZUl0dmNqTTEwYzdtV0d5d0d5MkNIS2JOVlA4ZTlnT25fVmx3UWNqc25DRkpTMXgwV2cxN0JBY0ltczZNRmQ1RHc4cGpSS1gyVUQ1WUktQ016NjFQM1VjRF9CX2ZTSWNybmVPUXJtY1h3Tm1aSVlFTVQzRzAtbTh5T0FNLWlvOEVHbUhzdlFXaThRUFB6VVNOZjU1S08tTFFWRUVOd2ExalpqaTczS2lLeGhTWl81NVJlNEJPQVZjeENUaTJSSjBrOVBDSjVndmp2OXN4cm0xZ2JQaTF4TE9MSEt5WEFrZEVQLXRPNEVpY0NabjJnN18tNmh4ejdvcl9jRDFVQ0JCeGN6ZzdlMUppbW1ISXFWcFV6cHp2S3oyU2dzX1V2YmNhNmVFM3JIcXVkS0QwaFBNWkJtcml2ZE91amVQSDFPdExMajNnY01vcE94emhOelZKX3hCcjdnclM3U1psX0xRTnhZZ2FaLWUwNDZrWEtIUmNaLUxROXNnVHZOY3lmMDZjMnphWG9VaTR3dHp0VVcyMnlsYktWeVpBUmxoeTJObWZ6dnV3WnA1bk1zRzNCbXdDQXU0SkYyb3owYzlrY1BIWXdTMU5tQS0yOHoyUTdLeW1KTHpMMWNVOV9CNmUtTVczMlRWTEFnNmY3enpsMmlkZ3RfeGtUZmVIRm0wVW42X3NGX29YYnRadXdsblFPUzdibENRYnlwOGRHWTdJZ2tKR195OTc3OXpDX0pMQXN6S0J2T05YVm9mTTdHNW4yZk1yQ3Z1TG1HWXpTMU1qRHVOOVNmZjBJZHVQZGM5WnVvN1VVdTFPZUc3NlotTkR1X0o4RzJXSTJadlczOTVjbmZnY1RnbENZSjlTd3FGSkRGVTRyYUtNVlZMb1lqSUlIRl85LUdJRVdyLUlkTFFTT0hXWTFhWjIxNWtVaktsaWpPcGdRMW9waEdBeGpDMXAzWXhWT19RdVkyOXEwUzRpTWFXOHlZbDF1Zk5TaWpuNk9VMENYOFotbHAyZXFkZUpkTFUxSUNyekxLWndVY2ViRGF3MF9VZEpYMkx4dDJ4NG5TY0M2MFQ3Tndpa2F0N19QMHQ4ZG1oSTJwWUp5LXl3ZUE5Sy1NS3ZzR01POG9MVjRULXlQMDhnaHhfc1hBcGpFRHE0NUctVUNKcS00cnI5NE9KTTFQcDg1MXBiU3hmNGt4OGVMZ01kbUpRbWhnbnpuT0xBU193WV83Vl81SFBiOGdYUmFZazRma0xFZVpwcWJ5MW05SGFvUFJ4MkZvX0dLUDdOM1VJRFJUdng2U2cwT1g0aHlTaUtqOGdQWTNUWTBFTGt2X09tdzBiQTBCR2ZWUE1uQmYyLUl4RDR0Q3V1azNlWWIyTXI1TG55N0tVMmlvNmlNS1hjWS1VZmdaMUxONEg4eHVhTmVaeENjWmpGbVY1bmYyNlJCWTBpejkyb25uTmY0Mk9XLUNjWUFBOG5wbHJ0WUlCejFHTmRybS03WkxzTVhuVHNTMlZWRzlYcE9teEl0ak1KOGZ2NTlQQlcyeXNZU0dTSTc3bEZyQ2ZoVE1xYW1kVFktUFBLZnhYLXB2NVE1T3dJeThTUkhUTHZsclA2NjJGZUhaX214OVNQMEV1dEtLcFpFNG1JLVdvZm92YXFTVzM1cmZVZkZIR3doM0tzb25mcExSTHl3MjZPWllkWFNuQm9QRnBTUktKanhPRG1IekFyWWMtNjJxcWJ3Rm9pWG14VExJcHBDQUkwYXBTY05tOFdBNGFUeFU3T21iYzYwRFJ1T2FNN3FZRVhUaE9JblBXRnJfb1dQV2xudnhmSlhWRFdUX0hQVDU2bU1oM0NFOFB3cW11QlhoNEVTMkFRLVU5Z1Vmd1ZRTFI2Snc3cWZkb1dPNVBCMmVlLW1acW0xWU5uZkVtR3pLQTdWM3plQU5kSUQ5MmUzc2VQRk9fUWZCQVdXVnpERFpGdFk5MUJwUUtsVlZ5OFEzTlBVWHBUY0Y3SUVZcGliV29JOFU2YjMwR3kyTllWU2trM3EtVFhxTVBMdW9XRks1QUl6cl9mX0IxaFBzUVcyNWhZdjQ5RDdCekJrN0hCaXpTcWVITkx4LUF0Tk8wYTBseU42VXdqTmdhUnlFRmQ3M2JXRnVpUHVfTlhoLUVtdHhpS0RwMWlsZXUzazkyVG44bEh2OFR0WENFWkhUa3RBdFBCLXVLZDJrNjdVRFd0U2pxcFdyNllVa2Z6VjNsMk5CWUpXUWpYLXMwdktFV1A0a1VmdnhNNGxudjU1YzhOVjdkUWZaQ1REeTJla3EwWVQwVlpSRmZGTll2VG1Rd2NpazNBT1NJVWxTSnRPQWFyM0ZETlFhWlZoQmh0ajY2TFl1Yzdac1A0VEQtRnZKQ3gta2RvamphNko0c1JMVWZDWEJVZzN1NVQ2UGltSDNHOXpYbkNsdEVZdWpJNTJYZ0V6RTJabGs4Z0JSdjlreERoRVBaUnhSenBKVXBJNGdrNGpZV0hnb0g2UXA4UUZwMkxocVhqMVlCSVdpZ1dOdTROMHQ5c1FmaG04X1hjc2dhanVjLXpXbWxwWV81MmZhWVp1M24waG1aSEk3ZlMwNDhtUS1HTk9BVENoakNWbXJwMnJiQXdNbFlpVXhJbllTTVBLaUhZTXhBWWxBWW1vNnpLaW5xWHpNdml1Y1dnWFlsamw0V2Y5SmdrMl9zams3bGl0N0RFSVFvQ3dlTS1KRXE2WDdPd0ZjcUZXZEE0VWNHTjFfS09hQ0ptR3FsRHpuZEhIbkFxb2lCUFdSVzJ5dmtnQWUxUVB2UEtkZERPbmx1X253b0NGU21XelhVSnMyaVMzbTF2ZjRBX0l0M2tlVG9wMkNQTXkxbDJtRXBfbmlYZEFjNUd5M0cxeDExTHBHMUdRYmNCMFFpZHJWVEQxLU5CZFhMSmNKeW5kaFBSWFN1WFZROUU3bUtrQUM4c0xqNkVodXdRaUFIVjR5cTBQQ1dpaGZOSVpheDY4NnlCaXFoVHQ5UTVnMFBLQXZfVy11WXFiQ0JtcXQ4TVVpcGJmc0dWNlJOajJxdkEyNFZFU2lfTlNLUUR1UUZaWnh3ZFBQZXN6b0J6d1hCQUpOdkZqeHpYY1lxUGxSdm1YMVpNbTdBS0VUWDhwcXZza3hKb05JcnN5SUpJYXdyYUxVQmFlRXpEeUhteDNMZDlYSkEwUlc1ajFpX3RsU0pSQ2hyZ3VDYUF0V1VveFJHbTZOZXVMNi10bVIxN2xEUWg1cWt2TzZOQ3hQTm13UGlSVkFTZG01NDNTeDNhNDlBejhLVGNsWXdpZWFuN1BzaEtCUzMteERsQTdDcDVOaS16ZkFCLXY5bHRKcjEwVTBvS29sYW1HaFFvOGFFWjFLV1hEcEEwTG5JVkMyM29EYnZvTlRsNXdmQzFWMlpSMnQxS2FydHMzTmVEUzlTQU5aSjJDWEhkRjU1U1lXMldjbnEyLW1ZSWduRUVPVE5QVGhzWkhlTUZIRUdLeVVmY1FLU0FkU0djWTBXLVRTU3lkeWY5Um1vWnB3OXhtaVpqYXM1R2lUb0o2RTdyOGFxS2trVHV6VU81cWpCcUZCeWRJWUE0NEk1ZmtvOTluOG5SZmJ4b3NmcVF2REhqLW1VbldWRzB1Zy1pV3kwRUdrYVhuaWJWRDZrSDJnZ2M2a3gwbDhNdUdoUzV0cmJMUTc1eUp0bkIycmNEc3ZKSnBYakJpV042b0pUS0dKUWtLQXNRa1pTYW5TQndpdUZTYlo5cmNNTUxCS0F3cjBncVo2Vkl0clJjZ3ZiczY3ZFlqMWZQdVRmbGFqZDE3UjJRZnlXZE9wOWxmUWRvZGNtdE1vQ3MtallIN0k3dERHdVE2MnA0bjE1RkxLY1hHLVdmd3BrN1kya3NzT2JVLWptbGIifQ"
            },
            "attributes": {
                "enabled": true,
                "nbf": 1671577355,
                "exp": 1703113355,
                "created": 1671577377,
                "updated": 1671827011,
                "recoveryLevel": "Recoverable+Purgeable",
                "recoverableDays": 90,
                "exportable": true
            },
            "tags": {},
            "release_policy": {
                "data": "eyJ2ZXJzaW9uIjoiMS4wLjAiLCJhbnlPZiI6W3siYXV0aG9yaXR5IjoiaHR0cHM6Ly9zaGFyZWR3ZXUud2V1LmF0dGVzdC5henVyZS5uZXQiLCJhbGxPZiI6W3siY2xhaW0iOiJ4LW1zLWlzb2xhdGlvbi10ZWUueC1tcy1hdHRlc3RhdGlvbi10eXBlIiwiZXF1YWxzIjoic2V2c25wdm0ifSx7ImNsYWltIjoieC1tcy1pc29sYXRpb24tdGVlLngtbXMtY29tcGxpYW5jZS1zdGF0dXMiLCJlcXVhbHMiOiJhenVyZS1jb21wbGlhbnQtY3ZtIn1dfV19",
                "immutable": false
            }
        }
    }
}
```

Should you base64url decode the value under `$.response.key.release_policy.data`, you will get the JSON representation of the Key Vault key release policy that we defined in the [assets folder](assets).

The `hsm_key` property its base64url decoded value looks like this:

```json
{
    "schema_version": "1.0",
    "header": {
        "kid": "TpmEphemeralEncryptionKey", // key identifier of key encryption key
        "alg": "dir", // Direct mode, i.e. the referenced kid is used to directly protect the ciphertext
        "enc": "CKM_RSA_AES_KEY_WRAP"
    },
    "ciphertext": "RftxvrWt7bWjt9HZhyGmtiszXT_9OD4mY2tVG97GMJiNZEKrfH_Vb6CT8GOQq_0L993j-JpnIrfSwBNVM7eraPqOmHTBs__0B0y-W3D3b04t7G3vzpI6gfs2YNM4hUDVZABZA5tRKkc66CZw6PG_xHUvJPz4wRJdMTXo5poPdVaWZl7FoM6NaMp8bmq_hhhl1ixYWb8iL3ULuEuoP3Bm6uI18fgfP7ULh1tMIE4D8DJzhbgl8X20haJ6WHqWOtTVWj3vSaaPqUtJnBjfRmmCm4DvbfUuhj41Upx471XpIxJMWyQ7unIAOOCIB3sOcupXQsXdRql8yrCAKfnQ9WLyE2OZVVfxAhr74Y7YK-q28ceQx-W6dFPhKoZzYEB326J6NBwR8DCDlBO0HcPatiJjzVG8F7asaLvPFW2RI4iN24MfGTu9GZv5LRaW-Blk6f6tuZY5y6Z0KTolNMV16PEQuBg0b7ZCWos0Eq2Xuk1kkL--zXgidq3w0e7ph6ubSy3ZICYZ0S-2GvY77wd1z3jaAttaeNjcK-qdRb5hJJMIg_Ad7qqtjep3B1MylnPjXmd1bKPBTelpCqOhfnCfyxHu54XeItvcjM10c7mWGywGy2CHKbNVP8e9gOn_VlwQcjsnCFJS1x0Wg17BAcIms6MFd5Dw8pjRKX2UD5YI-CMz61P3UcD_B_fSIcrneOQrmcXwNmZIYEMT3G0-m8yOAM-io8EGmHsvQWi8QPPzUSNf55KO-LQVEENwa1jZji73KiKxhSZ_55Re4BOAVcxCTi2RJ0k9PCJ5gvjv9sxrm1gbPi1xLOLHKyXAkdEP-tO4EicCZn2g7_-6hxz7or_cD1UCBBxczg7e1JimmHIqVpUzpzvKz2Sgs_Uvbca6eE3rHqudKD0hPMZBmrivdOujePH1OtLLj3gcMopOxzhNzVJ_xBr7grS7SZl_LQNxYgaZ-e046kXKHRcZ-LQ9sgTvNcyf06c2zaXoUi4wtztUW22ylbKVyZARlhy2NmfzvuwZp5nMsG3BmwCAu4JF2oz0c9kcPHYwS1NmA-28z2Q7KymJLzL1cU9_B6e-MW32TVLAg6f7zzl2idgt_xkTfeHFm0Un6_sF_oXbtZuwlnQOS7blCQbyp8dGY7IgkJG_y9779zC_JLAszKBvONXVofM7G5n2fMrCvuLmGYzS1MjDuN9Sff0IduPdc9Zuo7UUu1OeG76Z-NDu_J8G2WI2ZvW395cnfgcTglCYJ9SwqFJDFU4raKMVVLoYjIIHF_9-GIEWr-IdLQSOHWY1aZ215kUjKlijOpgQ1ophGAxjC1p3YxVO_QuY29q0S4iMaW8yYl1ufNSijn6OU0CX8Z-lp2eqdeJdLU1ICrzLKZwUcebDaw0_UdJX2Lxt2x4nScC60T7Nwikat7_P0t8dmhI2pYJy-yweA9K-MKvsGMO8oLV4T-yP08ghx_sXApjEDq45G-UCJq-4rr94OJM1Pp851pbSxf4kx8eLgMdmJQmhgnznOLAS_wY_7V_5HPb8gXRaYk4fkLEeZpqby1m9HaoPRx2Fo_GKP7N3UIDRTvx6Sg0OX4hySiKj8gPY3TY0ELkv_Omw0bA0BGfVPMnBf2-IxD4tCuuk3eYb2Mr5Lny7KU2io6iMKXcY-UfgZ1LN4H8xuaNeZxCcZjFmV5nf26RBY0iz92onnNf42OW-CcYAA8nplrtYIBz1GNdrm-7ZLsMXnTsS2VVG9XpOmxItjMJ8fv59PBW2ysYSGSI77lFrCfhTMqamdTY-PPKfxX-pv5Q5OwIy8SRHTLvlrP662FeHZ_mx9SP0EutKKpZE4mI-WofovaqSW35rfUfFHGwh3KsonfpLRLyw26OZYdXSnBoPFpSRKJjxODmHzArYc-62qqbwFoiXmxTLIppCAI0apScNm8WA4aTxU7Ombc60DRuOaM7qYEXThOInPWFr_oWPWlnvxfJXVDWT_HPT56mMh3CE8PwqmuBXh4ES2AQ-U9gUfwVQLR6Jw7qfdoWO5PB2ee-mZqm1YNnfEmGzKA7V3zeANdID92e3sePFO_QfBAWWVzDDZFtY91BpQKlVVy8Q3NPUXpTcF7IEYpibWoI8U6b30Gy2NYVSkk3q-TXqMPLuoWFK5AIzr_f_B1hPsQW25hYv49D7BzBk7HBizSqeHNLx-AtNO0a0lyN6UwjNgaRyEFd73bWFuiPu_NXh-EmtxiKDp1ileu3k92Tn8lHv8TtXCEZHTktAtPB-uKd2k67UDWtSjqpWr6YUkfzV3l2NBYJWQjX-s0vKEWP4kUfvxM4lnv55c8NV7dQfZCTDy2ekq0YT0VZRFfFNYvTmQwcik3AOSIUlSJtOAar3FDNQaZVhBhtj66LYuc7ZsP4TD-FvJCx-kdojja6J4sRLUfCXBUg3u5T6PimH3G9zXnCltEYujI52XgEzE2Zlk8gBRv9kxDhEPZRxRzpJUpI4gk4jYWHgoH6Qp8QFp2LhqXj1YBIWigWNu4N0t9sQfhm8_Xcsgajuc-zWmlpY_52faYZu3n0hmZHI7fS048mQ-GNOATChjCVmrp2rbAwMlYiUxInYSMPKiHYMxAYlAYmo6zKinqXzMviucWgXYljl4Wf9Jgk2_sjk7lit7DEIQoCweM-JEq6X7OwFcqFWdA4UcGN1_KOaCJmGqlDzndHHnAqoiBPWRW2yvkgAe1QPvPKddDOnlu_nwoCFSmWzXUJs2iS3m1vf4A_It3keTop2CPMy1l2mEp_niXdAc5Gy3G1x11LpG1GQbcB0QidrVTD1-NBdXLJcJyndhPRXSuXVQ9E7mKkAC8sLj6EhuwQiAHV4yq0PCWihfNIZax686yBiqhTt9Q5g0PKAv_W-uYqbCBmqt8MUipbfsGV6RNj2qvA24VESi_NSKQDuQFZZxwdPPeszoBzwXBAJNvFjxzXcYqPlRvmX1ZMm7AKETX8pqvskxJoNIrsyIJIawraLUBaeEzDyHmx3Ld9XJA0RW5j1i_tlSJRChrguCaAtWUoxRGm6NeuL6-tmR17lDQh5qkvO6NCxPNmwPiRVASdm543Sx3a49Az8KTclYwiean7PshKBS3-xDlA7Cp5Ni-zfAB-v9ltJr10U0oKolamGhQo8aEZ1KWXDpA0LnIVC23oDbvoNTl5wfC1V2ZR2t1Karts3NeDS9SANZJ2CXHdF55SYW2Wcnq2-mYIgnEEOTNPThsZHeMFHEGKyUfcQKSAdSGcY0W-TSSydyf9RmoZpw9xmiZjas5GiToJ6E7r8aqKkkTuzUO5qjBqFBydIYA44I5fko99n8nRfbxosfqQvDHj-mUnWVG0ug-iWy0EGkaXnibVD6kH2ggc6kx0l8MuGhS5trbLQ75yJtnB2rcDsvJJpXjBiWN6oJTKGJQkKAsQkZSanSBwiuFSbZ9rcMMLBKAwr0gqZ6VItrRcgvbs67dYj1fPuTflajd17R2QfyWdOp9lfQdodcmtMoCs-jYH7I7tDGuQ62p4n15FLKcXG-Wfwpk7Y2kssObU-jmlb"
}
```

## Managed identities

You can learn more about [managed identities](https://docs.microsoft.com/azure/app-service/overview-managed-identity) and common scenarios in the [documentation](https://docs.microsoft.com/azure/app-service/overview-managed-identity#obtaining-tokens-for-azure-resources).
