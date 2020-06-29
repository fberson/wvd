<#  
.SYNOPSIS  
    Contains functions to get & create WVD Workpaces, Hostpools, App Groups and apps using REST API
.DESCRIPTION  
    This contains the following functions that use REST API for WVD
    - Get-WorkSpace
    - Get-Hostpool
    - Get-AppGroup
    - Get-Apps
    - New-WorkSpace
    - New-Hostpool
    - New-AppGroup
    - New-App
.NOTES  
    File Name  : WVD-Rest-Api-Functions.ps1
    Author     : Freek Berson - Wortell - wvd.ninja :)
    Version    : v1.0.1
.DISCLAIMER
    Use at your own risk. This scripts are provided AS IS without warranty of any kind. The author further disclaims all implied
    warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk
    arising out of the use or performance of the scripts and documentation remains with you. In no event shall the author, or anyone else involved
    in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss
    of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability
    to use the this script.
#>


#Function to get the details of an existing WVD Workspace via REST API
function Get-WVDWorkspace {
    param
    (
        [Parameter(Mandatory=$true)]
        $AzureSubscriptionID,
        $ResourceGroupName,
        $WorkspaceName
    )
    $url = "https://management.azure.com/subscriptions/"+$AzureSubscriptionID+"/resourceGroups/"+ $ResourceGroupName+"/providers/Microsoft.DesktopVirtualization/workspaces/"+$WorkspaceName+"?api-version=2019-12-10-preview"
    $results = Invoke-RestMethod -Uri $url -Method Get -Headers $apiHeader
    return $results
}

#Function to get the details of an existing WVD Hostpool via REST API
function Get-WVDHostpool {
    param
    (
        [Parameter(Mandatory=$true)]
        $AzureSubscriptionID,
        $ResourceGroupName,
        $HostpoolName
    )
    $url = "https://management.azure.com/subscriptions/"+$AzureSubscriptionID+"/resourceGroups/"+ $ResourceGroupName+"/providers/Microsoft.DesktopVirtualization/hostPools/"+$HostpoolName+"?api-version=2019-12-10-preview"
    $results = Invoke-RestMethod -Uri $url -Method Get -Headers $apiHeader
    return $results
}

#Function to get the details of an existing WVD AppGroup via REST API
function Get-WVDAppGroup {
    param
    (
        [Parameter(Mandatory=$true)]
        $AzureSubscriptionID,
        $ResourceGroupName,
        $AppGroupName
    )
    $url = "https://management.azure.com/subscriptions/"+$AzureSubscriptionID+"/resourceGroups/"+$ResourceGroupName+"/providers/Microsoft.DesktopVirtualization/applicationGroups/"+$AppGroupName+"?api-version=2019-12-10-preview"
    $results = Invoke-RestMethod -Uri $url -Method Get -Headers $apiHeader
    return $results
}

#Function to get all Pubished Applications on an AppGroup via REST API
function Get-WVDApp {
    param
    (
        [Parameter(Mandatory=$true)]
        $AzureSubscriptionID,
        $ResourceGroupName,
        $AppGroupName
    )
    $url = "https://management.azure.com/subscriptions/"+$AzureSubscriptionID+"/resourceGroups/"+$ResourceGroupName+ "/providers/Microsoft.DesktopVirtualization/applicationGroups/"+$AppGroupName+"/applications?api-version=2019-12-10-preview"
    $results = Invoke-RestMethod -Uri $url -Method Get -Headers $apiHeader
    return $results
}

#Function to create a new WVD Hostpool via REST API
function New-WVDHostpool {
    param
    (
        [Parameter(Mandatory=$true)]
        $AzureSubscriptionID,
        $ResourceGroupName,
        $HostpoolName,
        $HostpoolBody
    )
    $url = "https://management.azure.com/subscriptions/"+$AzureSubscriptionID+"/resourceGroups/"+$ResourceGroupName+ "/providers/Microsoft.DesktopVirtualization/hostpools/"+$HostpoolName+"?api-version=2019-01-23-preview"
    $results = Invoke-RestMethod -Uri $url -Method Put -Headers $apiHeader -Body $HostpoolBody
    return $results
}

#Function to create a new WVD AppGroup via REST API
function New-WVDAppGroup {
    param
    (
        [Parameter(Mandatory=$true)]
        $AzureSubscriptionID,
        $ResourceGroupName,
        $AppGroupName,
        $AppGroupBody
    )
    $url = "https://management.azure.com/subscriptions/"+$AzureSubscriptionID+"/resourceGroups/"+$ResourceGroupName+"/providers/Microsoft.DesktopVirtualization/applicationGroups/"+$AppGroupName+"?api-version=2019-12-10-preview"
    $results = Invoke-RestMethod -Uri $url -Method Put -Headers $apiHeader -Body $AppGroupBody
    return $results
}

#Function to create a new WVD Workspace via REST API
function New-WVDWorkspace {
    param
    (
        [Parameter(Mandatory=$true)]
        $AzureSubscriptionID,
        $ResourceGroupName,
        $WorkspaceName,
        $WorkspaceBody
    )
    $url = "https://management.azure.com/subscriptions/"+$AzureSubscriptionID+"/resourceGroups/"+$ResourceGroupName+"/providers/Microsoft.DesktopVirtualization/workspaces/"+$WorkspaceName+"?api-version=2019-12-10-preview"
    $results = Invoke-RestMethod -Uri $url -Method Put -Headers $apiHeader -Body $WorkspaceBody
    return $results
}

#Function to create a new Pubished App via REST API
function New-WVDApp {
    param
    (
        [Parameter(Mandatory=$true)]
        $AzureSubscriptionID,
        $ResourceGroupName,
        $AppGroupName,
        $AppGroupBody,
        $AppName
    )
    $url = "https://management.azure.com/subscriptions/"+$AzureSubscriptionID+"/resourceGroups/"+$ResourceGroupName+ "/providers/Microsoft.DesktopVirtualization/applicationGroups/"+$AppGroupName+"/applications/"+$AppName+"?api-version=2019-12-10-preview"
    $results = Invoke-RestMethod -Uri $url -Method Put -Headers $apiHeaderApps -Body $AppGroupBody
    return $results
}


# Specify Variables here #
$AzureSubscriptionID = ""
$AzureIDTenantID = ""
$AppID = ""
$AppSecret = ""
$azureManagementURL = "https://management.azure.com"
$AuthTokenURL = "https://login.microsoftonline.com/$AzureIDTenantID/oauth2/token"
# End of Variables here #

#Create REST api Body and grab the API Authentication Token
$apiToken = Invoke-RestMethod -Method POST -uri $AuthTokenURL -Body `
(@{grant_type="client_credentials";client_Id=$AppID;client_Secret=$AppSecret;resource=$azureManagementURL})

#Concat the REST API header
$apiHeader = @{"Authorization"="$($apiToken.token_type) $($apiToken.access_token)"; “Content-Type" = “application/json"}

#Concat the REST API header
$apiHeaderApps = @{"Authorization"="$($apiToken.token_type) $($apiToken.access_token)"; “Content-Type" = “application/json; charset=utf-8"}



#Example values for ResourceGroup, Hostpool, AppGroup and Workspace
$ResourceGroupName = "NINJA-WE-P-RG-WVD-REST-TEST"
$HostpoolName = "NINJA-WE-P-RG-WVD-HOSTPOOL-TEST"
$AppGroupName ="NINJA-WE-P-RG-WVD-APPGROUP-TEST"
$WorkspaceName = "NINJA-WE-P-RG-WVD-WORKSPACE-TEST"
$ApplicationName = "Outlook"

#Example to get the details of existing WVD Workspace
$WVDWorkspace = Get-WVDWorkspace -AzureSubscriptionID $AzureSubscriptionID -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName

#Example to get the details of existing WVD Hostpool
$WVDHostPool = Get-WVDHostpool -AzureSubscriptionID $AzureSubscriptionID -ResourceGroupName $ResourceGroupName -HostpoolName $HostpoolName

#Example to get the details of existing WVD AppGroup
$WVDAppGroup = Get-WVDAppGroup -AzureSubscriptionID $AzureSubscriptionID -ResourceGroupName $ResourceGroupName -AppGroupName $AppGroupName

#Example to get all publisbed apps on an existing WVD AppGroup
$WVDApps = Get-WVDApp -AzureSubscriptionID $AzureSubscriptionID -ResourceGroupName $ResourceGroupName -AppGroupName $AppGroupName
$WVDApps.value.properties | select friendlyName,filePath,iconPath,commandLineSetting

#Example to create a new WVD Hostpool
$HostpoolBody = @"
{
    "name": "$HostpoolName",
    "type": "Microsoft.DesktopVirtualization/hostpools",
    "location": "eastus",
    "properties": {
        "description": "WVD Hostpool via REST",
        "hostPoolType": "Pooled",
        "customRdpProperty": "audiocapturemode:i:0;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:0;redirectprinters:i:1",
        "maxSessionLimit": 99999,
        "loadBalancerType": "BreadthFirst",
    }
}
"@
New-WVDHostpool -AzureSubscriptionID $AzureSubscriptionID -ResourceGroupName $ResourceGroupName -HostpoolName $HostpoolName  -HostpoolBody $HostpoolBody

#Example to create a new WVD AppGroup, linked to existing Hostpool
$AppGroupBody = @"
{
    "name": "$AppGroupName",
	"type": "Microsoft.DesktopVirtualization/applicationgroups",
	"location": "eastus",
	"kind": "Desktop",
	"properties": {
        "description": "WVD AppGroup via REST",
		"hostPoolArmPath": "/subscriptions/$AzureSubscriptionID/resourcegroups/$ResourceGroupName/providers/Microsoft.DesktopVirtualization/hostpools/$HostpoolName",
		"applicationGroupType": "RemoteApp"
	}
}
"@
New-WVDAppGroup -AzureSubscriptionID $AzureSubscriptionID -ResourceGroupName $ResourceGroupName -AppGroupName $AppGroupName -AppGroupBody $AppGroupBody

#Example to create a new WVD Workspace, linked to existing AppGroup
$WorkspaceBody = @"
{
    "name": "$WorkspaceName",
    "type": "Microsoft.DesktopVirtualization/workspaces",
    "location": "eastus",
    "properties": {
        "description": "WVD Workspace via REST",
        "friendlyName": "WVD Workspace via REST",
        "applicationGroupReferences": [
        "/subscriptions/$AzureSubscriptionID/resourcegroups/$ResourceGroupName/providers/Microsoft.DesktopVirtualization/applicationgroups/$AppGroupName"
        ]
    }
}
"@
New-WVDWorkspace -AzureSubscriptionID $AzureSubscriptionID -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName -WorkspaceBody $WorkspaceBody

#Example to create a new WVD Published App, linked to existing AppGroup
$AppBody = @"
{
    "name": "$AppGroupName/$ApplicationName",
    "type": "Microsoft.DesktopVirtualization/applicationgroups/applications",
    "location": "eastus",
    "properties": {
        "description": "WVD App Outlook via REST",
        "friendlyName": "Outlook",
        "filePath": "C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE",
        "commandLineSetting": "Allow",
        "commandLineArguments": "",
        "showInPortal": true,
        "iconPath": "C:\\Program Files\\Microsoft Office\\root\\Office16\\OUTLOOK.EXE",
        "iconIndex": 0,
    }
}
"@
New-WVDApp -AzureSubscriptionID $AzureSubscriptionID -ResourceGroupName $ResourceGroupName  -AppGroupName $AppGroupName -AppGroupBody $AppBody -AppName $ApplicationName






