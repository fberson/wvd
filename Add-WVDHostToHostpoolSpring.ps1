<#  
.SYNOPSIS  
    Adds an WVD Session Host to an existing WVD Hostpool *** SPRING UPDATE 2020***
.DESCRIPTION  
    This scripts adds an WVD Session Host to an existing WVD Hostpool by performing the following action:
    - Download the WVD agent
    - Download the WVD Boot Loader
    - Install the WVD Agent, using the provided hostpoolRegistrationToken
    - Install the WVD Boot Loader
    - Set the WVD Host into drain mode (optionally)
    - Create the Workspace <-> App Group Association (optionally)
    The script is designed and optimized to run as PowerShell Extension as part of a JSON deployment.
.NOTES  
    File Name  : dd-WVDHostToHostpoolSpring.ps1
    Author     : Freek Berson - Wortell - RDSGurus
    Version    : v1.3.6
.EXAMPLE
    .\Add-WVDHostToHostpool.ps1 -existingWVDWorkspaceName existingWVDWorkspaceName -existingWVDHostPoolName existingWVDHostPoolName `
      -existingWVDAppGroupName existingWVDAppGroupName -servicePrincipalApplicationId servicePrincipalApplicationId -servicePrincipalPassword servicePrincipalPassword -azureADTenantId azureADTenantId 
      -resourceGroupName resourceGroupName -azureSubscriptionId azureSubscriptionId -drainmode "Yes" -createWorkspaceAppGroupAsso createWorkspaceAppGroupAsso >> <yourlogdir>\dd-WVDHostToHostpoolSpring.log
.DISCLAIMER
    Use at your own risk. This scripts are provided AS IS without warranty of any kind. The author further disclaims all implied
    warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk
    arising out of the use or performance of the scripts and documentation remains with you. In no event shall the author, or anyone else involved
    in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss
    of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability
    to use the this script.
#>

[cmdletbinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$existingWVDWorkspaceName,
    [Parameter(Mandatory = $true)]
    [string]$existingWVDHostPoolName,
    [Parameter(Mandatory = $true)]
    [string]$existingWVDAppGroupName,
    [Parameter(Mandatory = $true)]
    [string]$servicePrincipalApplicationId,
    [Parameter(Mandatory = $true)]
    [string]$servicePrincipalPassword,
    [Parameter(Mandatory = $true)]
    [string]$azureADTenantId,
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$azureSubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]$drainmode,
    [Parameter(Mandatory = $true)]
    [string]$createWorkspaceAppGroupAsso
)

#Set Variables
$RootFolder = "C:\Packages\Plugins\"
$WVDAgentInstaller = $RootFolder + "WVD-Agent.msi"
$WVDBootLoaderInstaller = $RootFolder + "WVD-BootLoader.msi"

#Create Folder structure
if (!(Test-Path -Path $RootFolder))
{ 
    New-Item -Path $RootFolder -ItemType Directory
}

#Configure logging
function log
{
    param([string]$message)
    "`n`n$(get-date -f o)  $message" 
}

#Download and Import Modules
try
{
    log "Installing / importing modules"
    log "Installing nuget"
    Install-PackageProvider NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction Stop
    log "Installing Az.DesktopVirtualization"
    Install-Module -Name Az.DesktopVirtualization -Force -ErrorAction Stop
    log "Import-Module"
    Import-Module -Name Az.DesktopVirtualization -ErrorAction Stop
}
catch
{
    log "[ERROR] - $($_.Exception.Message)"
}

#Create ServicePrincipal Credential
log "Creating credentials"
$ServicePrincipalCreds = New-Object System.Management.Automation.PSCredential($servicePrincipalApplicationId, (ConvertTo-SecureString $servicePrincipalPassword -AsPlainText -Force))

#Set WVD Agent and Boot Loader download locations
$WVDAgentDownkloadURL = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
$WVDBootLoaderDownkloadURL = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"

#Authentication against the WVD Tenant
log "Authentication against the WVD Tenant"
try
{
    Connect-AzAccount -ServicePrincipal -Credential $servicePrincipalCreds -Tenant $azureADTenantId
}
catch
{
    log "[ERROR] - $($_.Exception.Message)"
}

#Obtain RdsRegistrationInfotoken
try
{
    log "Obtain RdsRegistrationInfotoken"
    $Registered = Get-AzWvdRegistrationInfo -SubscriptionId "$azureSubscriptionId" -ResourceGroupName "$resourceGroupName" -HostPoolName $existingWVDHostPoolName
}
catch
{
    log "[ERROR] - $($_.Exception.Message)"
}

if ($Registered.Token)
{ 
    #Token exists
    $registrationTokenValidFor = (New-TimeSpan -Start (Get-Date) -End $Registered.ExpirationTime | Select-Object Days, Hours, Minutes, Seconds) 
    log "Token is valid for: $registrationTokenValidFor"
}

if (!($Registered.Token) -or ($Registered.ExpirationTime -le (Get-Date)))
{
    #Create new token
    log "Creating new token"
    try
    {
        $Registered = New-AzWvdRegistrationInfo -SubscriptionId $azureSubscriptionId -ResourceGroupName $resourceGroupName -HostPoolName $existingWVDHostPoolName -ExpirationTime (Get-Date).AddHours(4)
    }
    catch
    {
        log "[ERROR] - $($_.Exception.Message)"
    }
}
$RdsRegistrationInfotoken = $Registered.Token

#Install the WVD Agent
Log "Install the WVD Agent"
Invoke-WebRequest -Uri $WVDAgentDownkloadURL -OutFile $WVDAgentInstaller
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $WVDAgentInstaller", "/quiet", "/qn", "/norestart", "/passive", "REGISTRATIONTOKEN=$RdsRegistrationInfotoken", "/l* C:\Users\AgentInstall.txt" -Wait

#Install the WVD Bootloader
Log "Install the Boot Loader"
Invoke-WebRequest -Uri $WVDBootLoaderDownkloadURL -OutFile $WVDBootLoaderInstaller
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $WVDBootLoaderInstaller", "/quiet", "/qn", "/norestart", "/passive", "/l* C:\Users\AgentBootLoaderInstall.txt" -Wait

#Set WVD Session Host in drain mode
if ($drainmode -eq "Yes")
{
    try
    {
        #Wait 1 minute to let the WVD host register before configuring Drain mode
        Start-sleep 60
        Log "Set WVD Session Host in drain mode"
        $CurrentHostName = [System.Net.Dns]::GetHostByName($env:computerName).hostname
        Update-AzWvdSessionHost -SubscriptionId "$azureSubscriptionId" -ResourceGroupName "$resourceGroupName" -HostPoolName $existingWVDHostPoolName -Name $CurrentHostName -AllowNewSession:$false
    }
    catch
    {
        log "[ERROR] - $($_.Exception.Message)"
    }
}

#Create Workspace-AppGroup Association
if ($createWorkspaceAppGroupAsso -eq "Yes")
{
    try
    {
        log "Create Workspace-AppGroup Association"
        Update-AzWvdWorkspace -SubscriptionId "$azureSubscriptionId" -ResourceGroupName "$resourceGroupName" -Name $existingWVDWorkspaceName -ApplicationGroupReference (Get-AzWvdApplicationGroup -SubscriptionId "$azureSubscriptionID" -ResourceGroupName "$resourceGroupName" -Name $existingWVDAppGroupName | Select-Object id).id
    }
    catch
    {
        log "[ERROR] - $($_.Exception.Message)"
    }
}

Log "Finished"
