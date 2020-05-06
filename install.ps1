Param
(
    [Parameter (Mandatory = $false)]
    [object]$inputJson,
    [string]$existingWVDWorkspaceName,
    [string]$existingWVDHostPoolName,
    [string]$existingWVDAPpGroupName,
    [string]$servicePrincipalApplicationID,
    [string]$servicePrincipalPassword,
    [string]$azureADTenantID,
    [string]$resourceGroupName,
    [string]$azureSubscriptionID,
    [string]$drainMode,
    [string]$createWorkspaceAppGroupAsso
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
    . .\Add-WVDHostToHostpoolSpring.ps1 $existingWVDWorkspaceName $existingWVDHostPoolName $servicePrincipalApplicationID $servicePrincipalPassword $azureADTenantID $resourceGroupName $azureSubscriptionID $Drainmode $createWorkspaceAppGroupAsso
}


Write-Log -logText "End"

Send-TeamsLogging -factsLogging $global:teamsLogging
