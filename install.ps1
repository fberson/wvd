Param
(
    [Parameter (Mandatory = $false)]
    [object]$inputJson
)
#
#$inputJson = @"
#{
#    "enableRemoting": {
#      "active": "yes"
#    },
#    "installWindowsDependencyAgent": {
#      "active": "no"
#    },
#    "formatDatadisk": {
#      "active": "yes"
#    }
#  }
#"@
#
## Convert object to actual JSON
try
{
    $json = $inputJson | ConvertFrom-Json
}
catch
{
    $inputJson | Out-File C:\Temp\inputJson.txt -Encoding utf8
}


. .\customscriptdefaults.ps1

if ($json.enableRemoting.active -eq "yes")
{
    Write-Log -logText "Enable Remoting"
    Enable-Remoting
}
if ($json.formatDatadisk.active -eq "yes")
{
    Write-Log -logText "Format extra disks"
    Enable-Disks
}
if ($json.installWindowsDependencyAgent.active -eq "yes")
{
    Write-Log -logText "Install Windows Dependency Agent"
    Install-WindowsDependencyAgent
}

if ($json.installSecureBaselineLGPO.active -eq "yes")
{
    Write-Log -logText "Install Azure Secure Baseline (LGPO)"
    Add-AzureSecureBaseline
}

if ($json.configureAsWVDManagementServer.active -eq "yes")
{
    Write-Log -logText "Confirguring as WVD Management Server"
    . .\Add-WVDHostToHostpoolSpring.ps1 $args[1] $args[2] $args[3] $args[4] $args[5] $args[6] $args[7] $args[8]
}


Write-Log -logText "End"

Send-TeamsLogging -factsLogging $global:teamsLogging
