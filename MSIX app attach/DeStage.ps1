#MSIX app attach de staging sample

#region variables
$packageName = "Notepadplusplus_1.0.0.0_x64__vcbnmdqcr7aap"
$msixJunction = "C:\temp\AppAttach\"
$vhdSrc="\\share\AppAttach\NotepadPlusPlus.vhd"
#endregion

#region deregister
Remove-AppxPackage -AllUsers -Package $packageName 
cd $msixJunction
Remove-Item $packageName -Force -Recurse
dismount-vhd -Path $vhdSrc
#endregion