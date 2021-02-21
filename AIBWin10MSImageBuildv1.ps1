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
    Version    : v2.0.0
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
$scriptStartTime = get-date

#Create temp folder
New-Item -Path 'C:\temp' -ItemType Directory -Force | Out-Null

#Download all source file async and wait for completion
$scriptActionStartTime = get-date
Write-host ('*** STEP 0 : Download all sources [ '+(get-date) + ' ]')
$files = @(
    @{url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.9/npp.7.8.9.Installer.exed"; path = "c:\temp\apps\notepadplusplus.exe"}
    @{url = "https://aka.ms/fslogix_download"; path = "c:\temp\apps\fslogix.zip"}
    @{url = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&download=true&managedInstaller=true&arch=x64"; path = "c:\temp\apps\Teams.msi"}
    @{url=  "https://go.microsoft.com/fwlink/?linkid=844652"; path = "c:\temp\apps\OneDriveSetup.exe"}
    @{url=  "https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso"; path = "c:\temp\apps\19041.1.191206-1406.vb_release_amd64fre_FOD-PACKAGES_OEM_PT1_amd64fre_MULTI.iso"}
    @{url=  "https://software-download.microsoft.com/download/pr/19041.1.191206-1406.vb_release_CLIENTLANGPACKDVD_OEM_MULTI.iso"; path = "c:\temp\apps\19041.1.191206-1406.vb_release_CLIENTLANGPACKDVD_OEM_MULTI.iso"}
)
$workers = foreach ($f in $files)
{ 
    $wc = New-Object System.Net.WebClient
    Write-Output $wc.DownloadFileTaskAsync($f.url, $f.path)
}
$workers.Result
$scriptActionDuration = (get-date) - $scriptActionStartTime
Write-Host "Total source Download time: "$scriptActionDuration.Minutes "Minute(s), " $scriptActionDuration.seconds "Seconds and " $scriptActionDuration.Milliseconds "Milleseconds"

#Install FSLogix
$scriptActionStartTime = get-date
Write-host ('*** STEP 1 : Install FSLogix Apps [ '+(get-date) + ' ]')
Expand-Archive -Path 'C:\temp\apps\fslogix.zip' -DestinationPath 'C:\temp\apps\fslogix\'  -Force
Start-Sleep -Seconds 10
Start-Process -FilePath 'C:\temp\apps\fslogix\x64\Release\FSLogixAppsSetup.exe' -ArgumentList '/install /quiet /norestart' -Wait
$scriptActionDuration = (get-date) - $scriptActionStartTime
Write-Host "*** FSLogix Install time: "$scriptActionDuration.Minutes "Minute(s), " $scriptActionDuration.seconds "Seconds and " $scriptActionDuration.Milliseconds "Milleseconds"

#Install Microsoft Teams
$scriptActionStartTime = get-date
Write-host ('*** STEP 3 : Install Microsoft Teams [ '+(get-date) + ' ]')
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Name 'IsWVDEnvironment' -Value 1 -PropertyType DWORD -Force | Out-Null
Start-Sleep -Seconds 30
Start-Process 'msiexec.exe' -ArgumentList '/i C:\temp\apps\Teams.msi /quiet /l*v C:\temp\apps\teamsinstall.log ALLUSER=1' -Wait
$scriptActionDuration = (get-date) - $scriptActionStartTime
Write-Host "*** Microsoft Teams Install time: "$scriptActionDuration.Minutes "Minute(s), " $scriptActionDuration.seconds "Seconds and " $scriptActionDuration.Milliseconds "Milleseconds"

#Install Onedrive per machine
$scriptActionStartTime = get-date
Write-host ('*** STEP 5 : Install Microsoft OneDrive per machine [ '+(get-date) + ' ]')
Start-Process -FilePath 'C:\temp\apps\OneDriveSetup.exe' -ArgumentList '/allusers'
$scriptActionDuration = (get-date) - $scriptActionStartTime
Write-Host "*** Onedrive per machine Install time: "$scriptActionDuration.Minutes "Minute(s), " $scriptActionDuration.seconds "Seconds and " $scriptActionDuration.Milliseconds "Milleseconds"

#Remove undeeded appx
$scriptActionStartTime = get-date
Write-host ('*** STEP 7 : Remove undeeded appx [ '+(get-date) + ' ]')
$appname = @(
"*windowscommunicationsapps*"
"*officehub*"
"*xbox*"
"*music*"
"*Solitaire*"
"*mixed*"
"*OneConnect*"
"*BingWeather*"
"*GetHelp*"
"*Getstarted*"
"*Messaging*"
"*Print3D*"
"*SkypeApp*"
"*Microsoft.People*"
"*Wallet*"
"*Microsoft.Windows.Photos*"
"*WindowsAlarms*"
"*WindowsMaps*"
"*YourPhone*"
"*Zune*"
"*WindowsSoundRecorder*"
"*Microsoft3DViewer*"
)
ForEach($app in $appname){
Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}
$scriptActionDuration = (get-date) - $scriptActionStartTime
Write-Host "*** Remove undeeded appx time: "$scriptActionDuration.Minutes "Minute(s), " $scriptActionDuration.seconds "Seconds and " $scriptActionDuration.Milliseconds "Milleseconds"

#Disable Internet Explorer
$scriptActionStartTime = get-date
Write-host ('*** STEP 8 : Disable Internet Explorer [ '+(get-date) + ' ]')
Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online -NoRestart
$scriptActionDuration = (get-date) - $scriptActionStartTime
Write-Host "*** Disable Internet Explorer time: "$scriptActionDuration.Minutes "Minute(s), " $scriptActionDuration.seconds "Seconds and " $scriptActionDuration.Milliseconds "Milleseconds"

#Finish up
$scriptTotalTime = (get-date) - $scriptStartTime
Write-Host "*** Script grand total time: "$scriptTotalTime.Minutes "Minute(s), " $scriptTotalTime.seconds "Seconds and " $scriptTotalTime.Milliseconds "Milleseconds"
