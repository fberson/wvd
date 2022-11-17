<#  
.SYNOPSIS  
    Creates an MSIX app attach (vhd) container for a given MSIX application
.DESCRIPTION  
    This scripts creates an MSIX app attach (vhd) container for a given MSIX files by:
    - Creating a new VHD disk
    - Initializing the disk
    - Creating a partition on the disk
    - Formatting the partition, including a customized label
    - Creating the MSIX parent folder
    - Extracting the MSIX into the parent folder on the mounted disk
    - Output the Volume ID and Package name needed for the Staging step of MSIX app attach
    - Dismount the disk

.NOTES  
    File Name  : create-MSIXAppAttachContainer.ps1
    Author     : Freek Berson - Wortell
    Version    : v1.0.3
.EXAMPLE
    .\create-MSIXAppAttachContainer.ps1
.DISCLAIMER
    Use at your own risk. This scripts are provided AS IS without warranty of any kind. The author further disclaims all implied
    warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk
    arising out of the use or performance of the scripts and documentation remains with you. In no event shall the author, or anyone else involved
    in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss
    of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability
    to use the this script.
#>

#Variables (below are sample values, change them accordingly before running the script)
$MSIXSourceLocation = "C:\MSIX\2.MSIX-packages\"
$MSIXAppAttachDestinationPath = "C:\MSIX\3.MSIX-app-attach\"
$MSIXSourceFiles = @("NotepadPlusPlus.msix")
$MSIXappattachContainerSizeMb = 100MB
$MSIXappattachContainerLabel = "NotepadPlusplus"
$MSIXappattachContainerRootFolder = "NotepadPlusplus"
$MSIXMGRLocation = "C:\Program Files\msixmgr\x64\"
$MSIXappattachContainerExtension = ".vhd"

Clear-Host
$Starttime = get-date

#Create new VHD
if (Test-Path -path ($MSIXAppAttachDestinationPath+$MSIXappattachContainerLabel+$MSIXappattachContainerExtension) -PathType Leaf){Write-Host "VHD Already exists, exiting" -ForegroundColor Red;return}
New-VHD -SizeBytes $MSIXappattachContainerSizeMb -Path ($MSIXAppAttachDestinationPath+$MSIXappattachContainerLabel+$MSIXappattachContainerExtension) -Dynamic -Confirm:$false  

#Mount the VHD
$vhdObject = Mount-VHD ($MSIXAppAttachDestinationPath+$MSIXappattachContainerLabel+$MSIXappattachContainerExtension) -Passthru

#Initialize disk
$disk = Initialize-Disk -Passthru -Number $vhdObject.Number

#Create parition
$partition = New-Partition -AssignDriveLetter -UseMaximumSize -DiskNumber $disk.Number

#Format Partition
Format-Volume -FileSystem NTFS -Confirm:$false -DriveLetter $partition.DriveLetter -NewFileSystemLabel $MSIXappattachContainerLabel -Force

#Create MSIX Root Folder 
New-Item -Path ($partition.DriveLetter+":\"+$MSIXappattachContainerRootFolder) -ItemType Directory

#Extract the MSIX into the app attach container (vhd)
foreach ($MSIXSourceFile in $MSIXSourceFiles)
{
    $msixmgRresult = Start-Process -FilePath ("`"" + $MSIXMGRLocation + "msixmgr.exe" +"`"") -ArgumentList ("-Unpack -packagePath `"" + ($MSIXSourceLocation+$MSIXSourceFile) + "`" -destination `"" + ($partition.DriveLetter+":\"+$MSIXappattachContainerRootFolder) +"`" -applyacls") -Wait | Wait-process
    #Grab the Volume info needed for the Staging part of MSIX app attach
    Write-Host "Completed transforming:"$MSIXSourceFile -ForegroundColor green
}
Write-Host "Disk Volume ID:" ((Get-Volume -DriveLetter $partition.DriveLetter | Select-Object UniqueId).UniqueId | out-string).Substring(11,((Get-Volume -DriveLetter $partition.DriveLetter | select UniqueId).UniqueId.Length-13)) -ForegroundColor Cyan
Write-Host "Package Names:" -ForegroundColor green
(Get-ChildItem -Path ($partition.DriveLetter+":\"+$MSIXappattachContainerRootFolder) | Select-Object Name).name 

#Dismount the VHD
Dismount-VHD ($MSIXAppAttachDestinationPath+$MSIXappattachContainerLabel+$MSIXappattachContainerExtension)
Write-Host "Disk is dismounted and ready"

Write-Host "Finished! Total transformation time:"((get-date) - $Starttime).Minutes "Minute(s) and" ((get-date) - $Starttime).seconds "Seconds."
