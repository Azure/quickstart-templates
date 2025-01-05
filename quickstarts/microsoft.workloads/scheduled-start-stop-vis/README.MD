---
description: This template creates a Logic App to automate for start and stop of SAP systems and underlying VMs.
page_type: sample
products:
- azure
- azure-resource-manager
- office365
urlFragment: scheduled-start-stop-vis
languages:
- json
---
# Schedule automated SAP system start & stop.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.workloads%2Fscheduled-start-stop-vis%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.workloads%2Fscheduled-start-stop-vis%2Fazuredeploy.json)

This template deploys a **Scheduler Logic App**. The **Scheduler Logic App** provides a logic app that can start or stop VIS (SAP) and underlying infrastructure at provided recurrent schedule.

`Tags: LogicApps, Scheduler, Microsoft.Logic/workflows, Request, object, integer, string, If, Scope, Terminate, Response, Workflow, InitializeVariable, Microsoft.Resources/deployments, Wait, IncrementVariable, Http`

## Solution overview and deployed resources

The SapOpsSchedule logic app acts as an time keeper that will execute the start or stop operation on the list of Virtual Instance for SAP resources on a schedule passed in as input to the request. Each Virtual Instance for SAP resource will be started/stopped parallely on the provided scheduled on recurring basis.

Since start and stop operations are to be performed at different schedules, you should deploy separate Logic App for start and stop schedule.

The following resources are deployed as part of the solution:

#### Logic Apps

Logic Apps provides serverless event triggered workflows that integrate disparate services inside and outside of Azure as well as on-prem.

+ **SapOpsSchedule LogicApp**: Logic App definition that acts as timekeeper and executes the operation on Virtual Instance for SAP resource at a provided recurring schedule.

#### API Connection

## Prerequisites

None.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

### Customize


### Management



## Notes

Learn more about Logic Apps

+ **[Azure Center for SAP Solutions Overview](https://learn.microsoft.com/en-us/azure/sap/center-sap-solutions/overview)**
+ **[Azure Logic Apps Overview](https://docs.microsoft.com/azure/logic-apps/logic-apps-overview)**
+ See **[Scheduling in Logic Apps](https://docs.microsoft.com/azure/connectors/connectors-native-recurrence#trigger-details)** to better understand how recurrence works
