---
page_type: resources
languages:
  - md
  - powershell
description: |
  Windows Virtual Desktop (WVD) - resources and scripts
products:
  - azure
  - windows-virtual-desktop
---

#  Windows Virtual Desktop (WVD) - resources and scripts


## Contents


| File/folder                         | Description                                                                         |
|-------------------------------------|-------------------------------------------------------------------------------------|
| `Add-WVDHostToHostpoolSpring.ps1`   | Adds an WVD Session Host to an existing WVD Hostpool                                |
| `Create-MSIXAppAttachContainer.ps1` | Creates an MSIX app attach (vhd) container for a given MSIX application             |
| `WVD-Rest-Api-Functions.ps1`        | Contains functions and exmaples to get & create WVD object using REST API           |
| `Create-WVD-Backplane.bicep`        | To build the ARM JSON code to create WVD back plane components in Azure             |
| `BicepModules`                      | Contains various Bicep Modules to create an WVD environment incl other components   |


## Add-WVDHostToHostpoolSpring.ps1
This script adds an WVD Session Host to an existing WVD Hostpool by performing the following action:
 - Download the WVD agent
 - Download the WVD Boot Loader
 - Install the WVD Agent, using the provided hostpoolRegistrationToken
 - Install the WVD Boot Loader
 - Set the WVD Host into drain mode (optionally)
 - Create the Workspace <-> App Group Association (optionally)
The script is designed and optimized to run as PowerShell Extension as part of a JSON deployment.

## Create-MSIXAppAttachContainer.ps1
This script creates an MSIX app attach (vhd) container for a given MSIX file by:
 - Creating a new VHD disk
 - Initializing the disk
 - Creating a partition on the disk
 - Formatting the partition, including a customized label
 - Creating the MSIX parent folder
 - Extracting the MSIX into the parent folder on the mounted disk
 - Output the Volume ID and Package name needed for the Staging step of MSIX app attach
 - Dismount the disk
 
 ## WVD-Rest-Api-Functions.ps1
This script contains the following functions that use REST API for WVD
 - Get-WorkSpace
 - Get-Hostpool
 - Get-AppGroup
 - Get-Apps
 - New-WorkSpace
 - New-Hostpool
 - New-AppGroup
 - New-App
 
  ## Create-WVD-Backplane.bicep
This Azure .bicep file (based on 0.1.1 Alpha Preview release of Project Bicep) generates the ARM Template (JSON) to create:
 - A WVD Workspace
 - A WVD Host pool
 - A WVD App Group
And connect the AppGroup with the Host pool

## Contributing

This project welcomes contributions and suggestions.

