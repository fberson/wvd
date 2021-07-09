#MSIX app attach registration sample

#region variables
$packageName = "Notepadplusplus_1.0.0.0_x64__vcbnmdqcr7aap"
$path = "C:\Program Files\WindowsApps\" + $packageName + "\AppxManifest.xml"
#endregion

#region register
Add-AppxPackage -Path $path -DisableDevelopmentMode -Register
#endregion