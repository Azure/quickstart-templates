// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'

//==============================================================================
// Parameters
//==============================================================================

@sys.description('Optional. Display name prefix to use for all workbooks. Default: "FinOps".')
param displayNamePrefix string = 'FinOps'

@sys.description('Optional. Indicates whether to deploy the optimization workbook. Default: true.')
param includeOptimization bool = true

@sys.description('Optional. Indicates whether to deploy the governance workbook. Default: true.')
param includeGovernance bool = true

@sys.description('Optional. Location of the resources. Default: Same as deployment. See https://aka.ms/azureregions.')
param location string = resourceGroup().location

@sys.description('Optional. Tags for all resources.')
param tags object = {}

@description('Optional. Tags to apply to resources based on their resource type. Resource type specific tags will be merged with tags for all resources.')
param tagsByResource object = {}

@sys.description('Optional. Enable telemetry to track anonymous module usage trends, monitor for bugs, and improve future releases.')
param enableDefaultTelemetry bool = true

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

// The last segment of the telemetryId is used to identify this module
var telemetryId = '00f120b5-2007-6120-0000-a7730126b006'
var finOpsToolkitVersion = loadTextContent('ftkver.txt')

// Add tags to all resources
var resourceTags = union(
  tags,
  tagsByResource[?'Microsoft.Insights/workbooks'] ?? {},
  {
    'ftk-version': finOpsToolkitVersion
    'ftk-tool': 'FinOps workbooks'
  }
)

//==============================================================================
// Resources
//==============================================================================

//------------------------------------------------------------------------------
// Telemetry
// Used to anonymously count the number of times the template has been deployed
// and to track and fix deployment bugs to ensure the highest quality.
// No information about you or your cost data is collected.
//------------------------------------------------------------------------------

resource defaultTelemetry 'Microsoft.Resources/deployments@2022-09-01' = if (enableDefaultTelemetry) {
  name: 'pid-${telemetryId}-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      metadata: {
        _generator: {
          name: 'FinOps toolkit'
          version: finOpsToolkitVersion
        }
      }
      resources: []
    }
  }
}

//------------------------------------------------------------------------------
// Workbooks
//------------------------------------------------------------------------------

module optimization 'workbooks/optimization/main.bicep' = if (includeOptimization) {
  name: '${displayNamePrefix}-Optimization'
  params: {
    displayName: '${displayNamePrefix} - Optimization'
    location: location
    tags: resourceTags
    enableDefaultTelemetry: false
  }
}

module governance 'workbooks/governance/main.bicep' = if (includeGovernance) {
  name: '${displayNamePrefix}-Governance'
  params: {
    displayName: '${displayNamePrefix} - Governance'
    location: location
    tags: resourceTags
    enableDefaultTelemetry: false
  }
}

//==============================================================================
// Outputs
//==============================================================================

@sys.description('Optimization workbook resource ID.')
output optimizationId string = optimization.outputs.workbookId

@sys.description('Optimization workbook Azure portal link.')
output optimizationUrl string = optimization.outputs.workbookUrl

@sys.description('Governance workbook resource ID.')
output governanceId string = governance.outputs.workbookId

@sys.description('Governance workbook Azure portal link.')
output governanceUrl string = governance.outputs.workbookUrl
