<#
.SYNOPSIS
    Installs the Azure Guest Attestation repository and AttestationClientApp binary on Windows.
.DESCRIPTION
    Installs the Azure Guest Attestation repository and AttestationClientApp binary on Windows.
    * Downloads the Azure Guest Attestation repository (https://github.com/Azure/confidential-computing-cvm-guest-attestation/), which includes the AttestationClientApp binary.
    * Installs the Microsoft C and C++ (https://docs.microsoft.com/en-US/cpp/windows/latest-supported-vc-redist?view=msvc-170) runtime libraries.
.INPUTS
    None.
.OUTPUTS
    None.
.EXAMPLE
    PS C:\> .\Install-AccGuestAttestation.ps1
#>

# Set the security protocol to TLS 1.2 or higher.
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
# Disable progress bars.
$ProgressPreference = 'SilentlyContinue'
# Downloads the Azure/confidential-computing-cvm-guest-attestation GitHub repository as a ZIP package.
Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/Azure/confidential-computing-cvm-guest-attestation/archive/refs/heads/main.zip" -OutFile "C:\confidential-computing-cvm-guest-attestation.zip"
# Expands the repository to C:\
Expand-Archive -Force -LiteralPath 'C:\confidential-computing-cvm-guest-attestation.zip' -DestinationPath "C:\"
# Expands the cvm_windows_attestation_client zip.
Expand-Archive -Force -LiteralPath "C:\confidential-computing-cvm-guest-attestation-main\cvm-platform-checker-exe\Windows\cvm_windows_attestation_client.zip" -DestinationPath "C:\confidential-computing-cvm-guest-attestation-main\cvm-platform-checker-exe\Windows\cvm_windows_attestation_client"
# Installs the required Microsoft C and C++ (MSVC) runtime libraries.
Invoke-Expression 'C:\confidential-computing-cvm-guest-attestation-main\cvm-platform-checker-exe\Windows\cvm_windows_attestation_client\cvm_windows_attestation_client\VC_redist.x64.exe /install /quiet /norestart /log "C:\confidential-computing-cvm-guest-attestation-main\cvm-platform-checker-exe\Windows\cvm_windows_attestation_client\cvm_windows_attestation_client\VC_redist.x64.exe.log"'
