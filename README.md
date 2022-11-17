#  Windows Virtual Desktop related content
This repository contains Windows Virtual Desktop (WVD) related resources and scripts. You can find ARM Templates, Bicep Tenmplates and PowerShell scripts to automate and manage
your Windows Virtual Desktop environment.

<img align="right" src="https://1.bp.blogspot.com/-4cExxWC9Wpo/YG71Y14tmLI/AAAAAAAAFMs/bhXFN9oT9_Ew2RTB71kwsZ2lY93bauHeACLcBGAsYHQ/s320/ninja-transparent.png">

##  Descriptions

### Add-WVDHostToHostpoolSpring.ps1
This script adds an WVD Session Host to an existing WVD Hostpool by performing the following action:
 - Download the WVD agent
 - Download the WVD Boot Loader
 - Install the WVD Agent, using the provided hostpoolRegistrationToken
 - Install the WVD Boot Loader
 - Set the WVD Host into drain mode (optionally)
 - Create the Workspace <-> App Group Association (optionally)
The script is designed and optimized to run as PowerShell Extension as part of a JSON deployment.

### Add-WVDHostToHostpoolSpringV2.ps1
Adds an WVD Session Host to an existing WVD Hostpool using a provided registrationKey by performing the following action:
 - Download the WVD agent
 - Download the WVD Boot Loader
 - Install the WVD Agent, using the provided hostpoolRegistrationToken
 - Install the WVD Boot Loader
The script is designed and optimized to run as PowerShell Extension as part of a JSON deployment.
V1 of this script generates its own host pool registrationkey, this V2 version accepts the registrationkey as a parameter

### Create-MSIXAppAttachContainer.ps1
This script creates an MSIX app attach (vhd) container for a given MSIX file by:
 - Creating a new VHD disk
 - Initializing the disk
 - Creating a partition on the disk
 - Formatting the partition, including a customized label
 - Creating the MSIX parent folder
 - Extracting the MSIX into the parent folder on the mounted disk
 - Output the Volume ID and Package name needed for the Staging step of MSIX app attach
 - Dismount the disk
 
 ### WVD-Rest-Api-Functions.ps1
This script contains the following functions that use REST API for WVD
 - Get-WorkSpace
 - Get-Hostpool
 - Get-AppGroup
 - Get-Apps
 - New-WorkSpace
 - New-Hostpool
 - New-AppGroup
 - New-App
 
  ### Create-WVD-Backplane.bicep
This Azure .bicep file (based on 0.1.1 Alpha Preview release of Project Bicep) generates the ARM Template (JSON) to create:
 - A WVD Workspace
 - A WVD Host pool
 - A WVD App Group
And connect the AppGroup with the Host pool

### Contributing

This project welcomes contributions and suggestions.

