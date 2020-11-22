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


| File/folder                          | Description                                                               |
|--------------------------------------|---------------------------------------------------------------------------|
| `1. Deploy-Modules.bicep`            | Bicep file that calls bicep modules to deploy WVD,vnet and log analytics  |
| `1.1 wvd-backplane-module.bicep`     | Bicep module that creates WVD Hostpool, AppGroup and Workspace            |
| `1.2. wvd-network-module.bicep`      | Bicep module that creates a vnet and subnet                               |
| `1.3. wvd-fileservices-module.bicep` | Bicep module that creates a storage account and file share                |
| `1.4. wvd-LogAnalytics.bicep`        | Bicep module that creates a log analytics workspace                       |
| `1.4.1. wvd-monitor-diag.bicep`      | Bicep module that configured diagnostic settings for WVD components       |
