# Azure Bicep Deployment Process Log

## Overview
This document logs the process of deploying a virtual machine using Azure Bicep. It includes challenges encountered while deploying locally and through Azure services.

---

## Process Summary

1. **Initial Attempt: Azure Virtual Machine Deployment**
   - **Objective**: Deploy a virtual machine using Azure CLI.
   - **Issue Encountered**: Subscription was inactive due to expired Azure Free Trial.
   - **Actions Taken**: Switched to local deployment using Azure Bicep.

---

## Local Deployment with Bicep

### Step 1: Setting Up Environment
- Installed necessary Azure CLI components:
  ```bash
  sudo apt-get install azure-cli
  az bicep install
  ```
- Verified installation:
  ```bash
  az version
  az bicep version
  ```

### Step 2: Creating a Resource Group
- Attempted to create a resource group:
  ```bash
  az group create --name mockResourceGroup --location eastus
  ```
- **Error**: Subscription not found.

### Step 3: Adjusting Deployment Scope
- Modified `main.bicep` to target `subscription` scope.
- Validated deployment configuration:
  ```bash
  az deployment sub validate \
    --location eastus \
    --template-file main.bicep \
    --parameters azuredeploy.parameters.json
  ```
- **Error**: Authorization issues due to missing role assignments.

### Step 4: Authentication Issues
- Re-authenticated using:
  ```bash
  az login --allow-no-subscriptions
  ```
- Checked account details:
  ```bash
  az account list --output table
  ```
- Verified permissions:
  ```bash
  az ad signed-in-user show
  az role assignment list --assignee "live.com#serena.sj@outlook.com" --all --output table
  ```

---

## Major Issues Encountered

1. **SubscriptionNotFound Errors**: Due to inactive Azure Free Trial.
2. **AuthorizationFailed Errors**: Missing permissions in Azure AD.
3. **Local Deployment Errors**: Invalid role assignments, incorrect scopes.

---

## Conclusion
Despite multiple debugging attempts, deployment failed due to inactive Azure subscriptions and insufficient permissions. Future steps could involve obtaining a new Azure subscription or using alternative cloud service providers.

---

*End of Log*
