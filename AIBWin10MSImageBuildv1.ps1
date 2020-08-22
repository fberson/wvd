<#  
.SYNOPSIS  
    Adds customizations inside an WVD Template Image
.DESCRIPTION  
    This makes a couple of demo purpose modifications to a WVD template image
     - Install Notepad++
     - Install FSLogix Apps
    The script is designed and optimized to run as part of an AIB deployment
.NOTES  
    File Name  : AIBWin10MSImageBuildv1.ps1
    Author     : Freek Berson - Wortell - RDSGurus
    Version    : v1.0.0
.EXAMPLE
    .\AIBWin10MSImageBuildv1.ps1
.DISCLAIMER
    Use at your own risk. This scripts are provided AS IS without warranty of any kind. The author further disclaims all implied
    warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk
    arising out of the use or performance of the scripts and documentation remains with you. In no event shall the author, or anyone else involved
    in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss
    of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability
    to use the this script.
#>


#Create temp folder
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null

#InstallNotepadplusplus
Invoke-WebRequest -Uri 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.9/npp.7.8.9.Installer.exe' -OutFile 'c:\temp\notepadplusplus.exe'
Invoke-Expression -Command 'c:\temp\notepadplusplus.exe /S'

#Start sleep
Start-Sleep -Seconds 10

#InstallFSLogix
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\temp\fslogix.zip'
Start-Sleep -Seconds 10
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Invoke-Expression -Command 'C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'

#Start sleep
Start-Sleep -Seconds 10

