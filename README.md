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


| File/folder                         | Description                                                             |
|-------------------------------------|-------------------------------------------------------------------------|
| `Add-WVDHostToHostpoolSpring.ps1`   | Adds an WVD Session Host to an existing WVD Hostpool                    |
| `Create-MSIXAppAttachContainer.ps1` | Creates an MSIX app attach (vhd) container for a given MSIX application |


## Add-WVDHostToHostpoolSpring.ps1
This scripts adds an WVD Session Host to an existing WVD Hostpool by performing the following action:
 - Download the WVD agent
 - Download the WVD Boot Loader
 - Install the WVD Agent, using the provided hostpoolRegistrationToken
 - Install the WVD Boot Loader
 - Set the WVD Host into drain mode (optionally)
 - Create the Workspace <-> App Group Association (optionally)
The script is designed and optimized to run as PowerShell Extension as part of a JSON deployment.

## Create-MSIXAppAttachContainer.ps1
This scripts creates an MSIX app attach (vhd) container for a given MSIX file by:
 - Creating a new VHD disk
 - Initializing the disk
 - Creating a partition on the disk
 - Formatting the partition, including a customized label
 - Creating the MSIX parent folder
 - Extracting the MSIX into the parent folder on the mounted disk
 - Output the Volume ID and Package name needed for the Staging step of MSIX app attach
 - Dismount the disk

## Contributing

This project welcomes contributions and suggestions.

