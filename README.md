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


| File/folder                       | Description                                          |
|-----------------------------------|------------------------------------------------------|
| `Add-WVDHostToHostpoolSpring.ps1` | Adds an WVD Session Host to an existing WVD Hostpool |


## Add-WVDHostToHostpoolSpring.ps1
This scripts adds an WVD Session Host to an existing WVD Hostpool by performing the following action:
 - Download the WVD agent
 - Download the WVD Boot Loader
 - Install the WVD Agent, using the provided hostpoolRegistrationToken
 - Install the WVD Boot Loader
 - Set the WVD Host into drain mode (optionally)
 - Create the Workspace <-> App Group Association (optionally)
The script is designed and optimized to run as PowerShell Extension as part of a JSON deployment.

## Contributing

This project welcomes contributions and suggestions.

