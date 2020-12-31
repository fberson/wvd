<#  
.SYNOPSIS  
    Adds an WVD Session Host to an existing WVD Hostpool using a provided registrationKey *** SPRING UPDATE 2020***
.DESCRIPTION  
    This scripts adds an WVD Session Host to an existing WVD Hostpool by performing the following action:
    - Download the WVD agent
    - Download the WVD Boot Loader
    - Install the WVD Agent, using the provided hostpoolRegistrationToken
    - Install the WVD Boot Loader
    The script is designed and optimized to run as PowerShell Extension as part of a JSON deployment.
    V1 of this script generates its own host pool registrationkey, this V2 version accepts the registrationkey as a parameter
.NOTES  
    File Name  : add-WVDHostToHostpoolSpringV2.ps1
    Author     : Freek Berson - Wortell - RDSGurus
    Version    : v1.0.0
.EXAMPLE
    .\add-WVDHostToHostpoolSpringV2.ps1 registrationKey >> <yourlogdir>\add-WVDHostToHostpoolSpringV2.log
.DISCLAIMER
    Use at your own risk. This scripts are provided AS IS without warranty of any kind. The author further disclaims all implied
    warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk
    arising out of the use or performance of the scripts and documentation remains with you. In no event shall the author, or anyone else involved
    in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss
    of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability
    to use the this script.
#>

#Get Parameters
$registrationKey = $args[0]

#Set Variables
$RootFolder = "C:\Packages\Plugins\"
$WVDAgentInstaller = $RootFolder+"WVD-Agent.msi"
$WVDBootLoaderInstaller = $RootFolder+"WVD-BootLoader.msi"

#Create Folder structure
if (!(Test-Path -Path $RootFolder)){New-Item -Path $RootFolder -ItemType Directory}

#Configure logging
function log
{
   param([string]$message)
   "`n`n$(get-date -f o)  $message" 
}

#Download all source file async and wait for completion
log  "Download WVD Agent & bootloader"
$files = @(
    @{url = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"; path = $WVDAgentInstaller}
    @{url = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"; path = $WVDBootLoaderInstaller}
)
$workers = foreach ($f in $files)
{ 
    $wc = New-Object System.Net.WebClient
    Write-Output $wc.DownloadFileTaskAsync($f.url, $f.path)
}
$workers.Result

#Install the WVD Agent
Log "Install the WVD Agent"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $WVDAgentInstaller", "/quiet", "/qn", "/norestart", "/passive", "REGISTRATIONTOKEN=$registrationKey", "/l* C:\Users\AgentInstall.txt" | Wait-process

#Wait to ensure WVD Agent has enough time to finish
Start-sleep 30

#Install the WVD Bootloader
Log "Install the Boot Loader"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $WVDBootLoaderInstaller", "/quiet", "/qn", "/norestart", "/passive", "/l* C:\Users\AgentBootLoaderInstall.txt" | Wait-process

Log "Finished"
