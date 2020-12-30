import-module az.desktopvirtualization
import-module az.network
import-module az.compute

$azureSubscriptionID = "66869840-a086-41d1-84e9-cf66ac8a9a94"
$resourceGroupName = "BICEP-WVD-DEMO-A-BACKPLANE-RG"
$existingWVDHostPoolName = "BICEP-A-WVD-HP"

$Registered = Get-AzWvdRegistrationInfo -SubscriptionId "$azureSubscriptionID" -ResourceGroupName "$resourceGroupName" -HostPoolName $existingWVDHostPoolName
if (-not(-Not $Registered.Token)){$registrationTokenValidFor = (NEW-TIMESPAN -Start (get-date) -End $Registered.ExpirationTime | select Days,Hours,Minutes,Seconds)}

$registrationTokenValidFor
if ((-Not $Registered.Token) -or ($Registered.ExpirationTime -le (get-date)))
{
    $Registered = New-AzWvdRegistrationInfo -SubscriptionId $azureSubscriptionID -ResourceGroupName $resourceGroupName -HostPoolName $existingWVDHostPoolName -ExpirationTime (Get-Date).AddHours(4) -ErrorAction SilentlyContinue
}
$RdsRegistrationInfotoken = $Registered.Token

Write-Host "##vso[task.setvariable variable=RdsRegistrationInfotoken;]$RdsRegistrationInfotoken"
