#MSIX app attach deregistration sample

#region variables
$packageName = "Notepadplusplus_1.0.0.0_x64__vcbnmdqcr7aap"
#endregion

#region deregister
Remove-AppxPackage -PreserveRoamableApplicationData $packageName
#endregion