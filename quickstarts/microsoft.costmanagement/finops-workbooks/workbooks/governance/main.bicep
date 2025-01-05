// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'

//==============================================================================
// Parameters
//==============================================================================

@sys.description('Optional. Display name for the workbook used in the Gallery. Must be unique in the resource group.')
param displayName string = 'Governance'

@sys.description('Optional. Location of the resources. Default: Same as deployment. See https://aka.ms/azureregions.')
param location string = resourceGroup().location

@sys.description('Optional. Workbook description.')
param description string = 'Reports to help you optimize your cost.'

@sys.description('Optional. Tags for all resources.')
param tags object = {}

@sys.description('Optional. Enable telemetry to track anonymous module usage trends, monitor for bugs, and improve future releases.')
param enableDefaultTelemetry bool = true

//------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------

var version = ''
var workbookJson = string(loadJsonContent('workbook.json'))

// The last segment of the telemetryId is used to identify this module
var workbookId = '907'
var telemetryId = '00f120b5-2007-6120-0000-${workbookId}30126b006'
var finOpsToolkitVersion = loadTextContent('ftkver.txt')

// Add tags to all resources
var resourceTags = contains(tags, 'ftk-tool') ? tags : union(tags, {
    'ftk-version': finOpsToolkitVersion
    'ftk-tool': '${displayName} workbook'
  })

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
// Workbook
//------------------------------------------------------------------------------

resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid(resourceGroup().id, 'Microsoft.Insights/workbooks', displayName)
  location: location
  tags: resourceTags
  kind: 'shared'
  properties: {
    category: 'workbook'
    description: description
    displayName: displayName
    serializedData: workbookJson
    sourceId: 'Azure Monitor'
    version: version
  }
}

//==============================================================================
// Outputs
//==============================================================================

@sys.description('The resource ID of the workbook.')
output workbookId string = workbook.id

@sys.description('Link to the workbook in the Azure portal.')
output workbookUrl string = '${environment().portal}/#view/AppInsightsExtension/UsageNotebookBlade/ComponentId/Azure%20Monitor/ConfigurationId/${uriComponent(workbook.id)}/Type/${workbook.properties.category}/WorkbookTemplateName/${uriComponent(workbook.properties.displayName)}'
