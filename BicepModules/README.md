---
page_type: resources
languages:
  - md
  - json
  - bicep
description: |
  Multi-module Bicep project that deploys a WVD environment in Azure
products:
  - azure
  - windows-virtual-desktop
---

#   Multi-module Bicep project for WVD - bicep files and json code


## Contents


| File/folder                          | Description                                                                    |
|--------------------------------------|--------------------------------------------------------------------------------|
| `1. Deploy-Modules.bicep`            | Main Bicep file that calls bicep modules to deploy WVD,vnet and log analytics  |
| `1.1 wvd-backplane-module.bicep`     | Bicep module that creates WVD Hostpool, AppGroup and Workspace                 |
| `1.2. wvd-network-module.bicep`      | Bicep module that creates a vnet and subnet                                    |
| `1.3. wvd-fileservices-module.bicep` | Bicep module that creates a storage account and file share                     |
| `1.4. wvd-LogAnalytics.bicep`        | Bicep module that creates a log analytics workspace                            |
| `1.4.1. wvd-monitor-diag.bicep`      | Bicep module that configured diagnostic settings for WVD components            |
| `1. Deploy-Modules.json`             | The JSON result after transpiling 1. Deploy-Modules.bicep                      |


## 1. Deploy-Modules.bicep
This main bicep file creates a WVD environment in Azure, based on Bicep 0.2 creating Resource Groups, WVD Backplane
components, Vnet with Subnet, Storage container with FileShare and Log Analytics Workspace. This main bicep files
calls the bicep modules as outlined below.
 - 1.1 wvd-backplane-module.bicep
 - 1.2. wvd-network-module.bicep
 - 1.3. wvd-fileservices-module.bicep
 - 1.4. wvd-LogAnalytics.bicep
 - 1.4.1. wvd-monitor-diag.bicep
The bicep file is based on Bicep 0.2

## 1.1 wvd-backplane-module.bicep
This Bicep Module creates WVD backplane components in Azure and connects all objects. The following objetcs
are created.
 - WVD Hostpool
 - WVD AppGroup
 - WVD Workspace
 This Bicep module can be run separatly or as part of Deploy-Modules.bicep
 
 ## 1.2. wvd-network-module.bicep
This Bicep Module creates networking components in Azure. The following objects are created.
 - Virtual Network
 - Subnet
 This Bicep module can be run separatly or as part of Deploy-Modules.bicep

 ## 1.3. wvd-fileservices-module.bicep
This Bicep Module creates File Services components in Azure. The following objects are created.
 - Storage Account
 - File Share
 This Bicep module can be run separatly or as part of Deploy-Modules.bicep

  ## 1.4. wvd-LogAnalytics.bicep
This Bicep Module creates Log Analytics components in Azure. The following objects are created.
 - Log Analytics Workspace
 This Bicep module can be run separatly or as part of Deploy-Modules.bicep

  ## 1.4.1. wvd-monitor-diag.bicep
This Bicep Module configures Log Analytics diagnostics settings for WVD components in Azure. The following objects
are configured for Log Analytics
 - Workspace
 - Hostpool
 This Bicep module can be run separatly or as part of Deploy-Modules.bicep

## 1. Deploy-Modules.json
This file is the JSON output after transpiling '1. Deploy-Modules.bicep'
The following command was used: bicep build '.\1. Deploy-Modules.bicep'

## Contributing

This project welcomes contributions and suggestions.
