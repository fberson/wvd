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
    File Name  : add-WVDHostToHostpoolSpringV3.ps1
    Author     : Freek Berson - Wortell - RDSGurus
    Version    : v1.0.0
.EXAMPLE
    .\add-WVDHostToHostpoolSpringV3.ps11 existingWVDWorkspaceName existingWVDHostPoolName `
      existingWVDAppGroupName servicePrincipalApplicationID servicePrincipalPassword azureADTenantID 
      resourceGroupName azureSubscriptionID Drainmode createWorkspaceAppGroupAsso >> <yourlogdir>\dd-WVDHostToHostpoolSpring.log
.DISCLAIMER
    Use at your own risk. This scripts are provided AS IS without warranty of any kind. The author further disclaims all implied
    warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk
    arising out of the use or performance of the scripts and documentation remains with you. In no event shall the author, or anyone else involved
    in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss
    of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability
    to use the this script.
#>


<#
.DESCRIPTION
Runs defined msi's to deploy RDAgent and Bootloader
.PARAMETER programDisplayName
.PARAMETER argumentList
.PARAMETER msiOutputLogPath
.PARAMETER isUninstall
.PARAMETER msiLogVerboseOutput
#>
function RunMsiWithRetry {
    param(
        [Parameter(mandatory = $true)]
        [string]$programDisplayName,

        [Parameter(mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$argumentList, 

        [Parameter(mandatory = $true)]
        [string]$msiOutputLogPath,

        [Parameter(mandatory = $false)]
        [switch]$isUninstall,

        [Parameter(mandatory = $false)]
        [switch]$msiLogVerboseOutput
    )
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    if ($msiLogVerboseOutput) {
        $argumentList += "/l*vx+ ""$msiOutputLogPath""" 
    }
    else {
        $argumentList += "/l*+ ""$msiOutputLogPath"""
    }

    $retryTimeToSleepInSec = 30
    $retryCount = 0
    $sts = $null
    do {
        $modeAndDisplayName = ($(if ($isUninstall) { "Uninstalling" } else { "Installing" }) + " $programDisplayName")

        if ($retryCount -gt 0) {
            Log -Message "Retrying $modeAndDisplayName in $retryTimeToSleepInSec seconds because it failed with Exit code=$sts This will be retry number $retryCount"
            Start-Sleep -Seconds $retryTimeToSleepInSec
        }

        Log -Message ( "$modeAndDisplayName" + $(if ($msiLogVerboseOutput) { " with verbose msi logging" } else { "" }))


        $processResult = Start-Process -FilePath "msiexec.exe" -ArgumentList $argumentList -Wait -Passthru
        $sts = $processResult.ExitCode

        $retryCount++
    } 
    while ($sts -eq 1618 -and $retryCount -lt 20) 

    if ($sts -eq 1618) {
        Log -Err "Stopping retries for $modeAndDisplayName. The last attempt failed with Exit code=$sts which is ERROR_INSTALL_ALREADY_RUNNING"
        throw "Stopping because $modeAndDisplayName finished with Exit code=$sts"
    }
    else {
        Log -Message "$modeAndDisplayName finished with Exit code=$sts"
    }

    return $sts
} 

<#
.DESCRIPTION
Uninstalls any existing RDAgent BootLoader and RD Infra Agent installations and then installs the RDAgent BootLoader and RD Infra Agent using the specified registration token.
.PARAMETER AgentInstallerFolder
Required path to MSI installer file
.PARAMETER AgentBootServiceInstallerFolder
Required path to MSI installer file
#>
function InstallRDAgents {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AgentInstallerFolder,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AgentBootServiceInstallerFolder,
    
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RegistrationToken,
    
        [Parameter(mandatory = $false)]
        [switch]$EnableVerboseMsiLogging
    )

    $ErrorActionPreference = "Stop"

    Log -Message "Boot loader folder is $AgentBootServiceInstallerFolder"
    $AgentBootServiceInstaller = $AgentBootServiceInstallerFolder + '\WVD-BootLoader.msi'

    Log -Message "Agent folder is $AgentInstallerFolder"
    $AgentInstaller = $AgentInstallerFolder + '\WVD-Agent.msi'

    if (!$RegistrationToken) {
        throw "No registration token specified"
    }

    $msiNamesToUninstall = @(
        @{ msiName = "Remote Desktop Services Infrastructure Agent"; displayName = "RD Infra Agent"; logPath = "$AgentInstallerFolder\AgentUninstall.txt"}, 
        @{ msiName = "Remote Desktop Agent Boot Loader"; displayName = "RDAgentBootLoader"; logPath = "$AgentInstallerFolder\AgentBootLoaderUnInstall.txt"}
    )
    
    foreach($u in $msiNamesToUninstall) {
        while ($true) {
            try {
                $installedMsi = Get-Package -ProviderName msi -Name $u.msiName
            }
            catch {
                if ($PSItem.FullyQualifiedErrorId -eq "NoMatchFound,Microsoft.PowerShell.PackageManagement.Cmdlets.GetPackage") {
                    break
                }
    
                throw;
            }
    
            $oldVersion = $installedMsi.Version
            $productCodeParameter = $installedMsi.FastPackageReference
    
            RunMsiWithRetry -programDisplayName "$($u.displayName) $oldVersion" -isUninstall -argumentList @("/x $productCodeParameter", "/quiet", "/qn", "/norestart", "/passive") -msiOutputLogPath $u.logPath -msiLogVerboseOutput:$EnableVerboseMsiLogging
        }
    }

    Log -Message "Installing RD Infra Agent on VM $AgentInstaller"
    RunMsiWithRetry -programDisplayName "RD Infra Agent" -argumentList @("/i $AgentInstaller", "/quiet", "/qn", "/norestart", "/passive", "REGISTRATIONTOKEN=$RegistrationToken") -msiOutputLogPath "C:\Users\AgentInstall.txt" -msiLogVerboseOutput:$EnableVerboseMsiLogging

    Start-sleep 30

    Log -Message "Installing RDAgent BootLoader on VM $AgentBootServiceInstaller"
    RunMsiWithRetry -programDisplayName "RDAgent BootLoader" -argumentList @("/i $AgentBootServiceInstaller", "/quiet", "/qn", "/norestart", "/passive") -msiOutputLogPath "C:\Users\AgentBootLoaderInstall.txt" -msiLogVerboseOutput:$EnableVerboseMsiLogging

    $bootloaderServiceName = "RDAgentBootLoader"
    $startBootloaderRetryCount = 0
    while ( -not (Get-Service $bootloaderServiceName -ErrorAction SilentlyContinue)) {
        $retry = ($startBootloaderRetryCount -lt 6)
        $msgToWrite = "Service $bootloaderServiceName was not found. "
        if ($retry) { 
            $msgToWrite += "Retrying again in 30 seconds, this will be retry $startBootloaderRetryCount" 
            Log -Message $msgToWrite
        } 
        else {
            $msgToWrite += "Retry limit exceeded" 
            Log -Err $msgToWrite
            throw $msgToWrite
        }
            
        $startBootloaderRetryCount++
        Start-Sleep -Seconds 30
    }

    Log -Message "Starting service $bootloaderServiceName"
    Start-Service $bootloaderServiceName
}

#Get Parameters
$existingWVDWorkspaceName = $args[0]
$existingWVDHostPoolName = $args[1]
$existingWVDAppGroupName = $args[2]
$servicePrincipalApplicationID = $args[3]
$servicePrincipalPassword = $args[4]
$azureADTenantID =  $args[5]
$resourceGroupName = $args[6]
$azureSubscriptionID = $args[7]
$drainmode = $args[8]
$createWorkspaceAppGroupAsso = $args[9]

#Set Variables
$RootFolder = "C:\Packages\Plugins\"
$WVDAgentInstaller = $RootFolder+"WVD-Agent.msi"
$WVDBootLoaderInstaller = $RootFolder+"WVD-BootLoader.msi"

#Create Folder structure
if (!(Test-Path -Path $RootFolder)){New-Item -Path $RootFolder -ItemType Directory}

#Download and Import Modules
install-packageProvider -Name NuGet -MinimumVErsion 2.8.5.201 -force
Install-Module -Name Az.DesktopVirtualization -AllowClobber -Force
Import-Module -Name Az.DesktopVirtualization

#Configure logging
function log
{
   param([string]$message)
   "`n`n$(get-date -f o)  $message" 
}

#Create ServicePrincipal Credential
log "Creating credentials"
$ServicePrincipalCreds = New-Object System.Management.Automation.PSCredential($servicePrincipalApplicationID, (ConvertTo-SecureString $servicePrincipalPassword -AsPlainText -Force))

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

#Authenticatie against the WVD Tenant
log "Authenticatie against the WVD Tenant"
Connect-AzAccount -ServicePrincipal -Credential $ServicePrincipalCreds  -Tenant $azureADTenantID

#Obtain RdsRegistrationInfotoken
log "Obtain RdsRegistrationInfotoken"
$Registered = Get-AzWvdRegistrationInfo -SubscriptionId "$azureSubscriptionID" -ResourceGroupName "$resourceGroupName" -HostPoolName $existingWVDHostPoolName
if (-not(-Not $Registered.Token)){$registrationTokenValidFor = (NEW-TIMESPAN -Start (get-date) -End $Registered.ExpirationTime | select Days,Hours,Minutes,Seconds)}
log "Token is valid for:$registrationTokenValidFor"
if ((-Not $Registered.Token) -or ($Registered.ExpirationTime -le (get-date)))
{
    $Registered = New-AzWvdRegistrationInfo -SubscriptionId $azureSubscriptionID -ResourceGroupName $resourceGroupName -HostPoolName $existingWVDHostPoolName -ExpirationTime (Get-Date).AddHours(4) -ErrorAction SilentlyContinue
}
$RdsRegistrationInfotoken = $Registered.Token

Log "Calling functions to install agent and bootloader"
InstallRDAgents -AgentBootServiceInstallerFolder $RootFolder -AgentInstallerFolder $RootFolder -RegistrationToken $RdsRegistrationInfotoken -EnableVerboseMsiLogging:$false

#Set WVD Session Host in drain mode
if ($drainmode -eq "Yes")
{
    #Wait 1 minute to let the WVD host register before configuring Drain mode
    Start-sleep 60
    Log "Set WVD Session Host in drain mode"
    $CurrentHostName = [System.Net.Dns]::GetHostByName($env:computerName).hostname
    Update-AzWvdSessionHost -SubscriptionId "$azureSubscriptionID" -ResourceGroupName "$resourceGroupName" -HostPoolName $existingWVDHostPoolName -Name $CurrentHostName -AllowNewSession:$false
}

#Create Workspace-AppGroup Association
if ($createWorkspaceAppGroupAsso -eq "Yes")
{
    Update-AzWvdWorkspace -SubscriptionId "$azureSubscriptionID" -ResourceGroupName "$resourceGroupName" -Name $existingWVDWorkspaceName -ApplicationGroupReference (Get-AzWvdApplicationGroup -SubscriptionId "$azureSubscriptionID" -ResourceGroupName "$resourceGroupName" -Name $existingWVDAppGroupName | select id).id
}

Log "Finished"
