#MSIX app attach staging sample

#region variables
$vhdSrc="\\share\AppAttach\NotepadPlusPLus.vhd"
$packageName = "Notepadplusplus_1.0.0.0_x64__vcbnmdqcr7aap"
$parentFolder = "NotepadPlusPLus"
$parentFolder = "\" + $parentFolder + "\"
$volumeGuid = "53e46305-4746-428e-a80f-2f8046a29e84"
$msixJunction = "C:\temp\AppAttach\"
#endregion

#region mountvhd
try
{
Mount-VHD -Path $vhdSrc -NoDriveLetter -ReadOnly
Write-Host ("Mounting of " + $vhdSrc + " was completed!") -BackgroundColor Green
}
catch
{
Write-Host ("Mounting of " + $vhdSrc + " has failed!") -BackgroundColor Red
}
#endregion

#region makelink
$msixDest = "\\?\Volume{" + $volumeGuid + "}\"
if (!(Test-Path $msixJunction))
{
md $msixJunction
}
$msixJunction = $msixJunction + $packageName
cmd.exe /c mklink /j $msixJunction $msixDest
#endregion

#region stage
[Windows.Management.Deployment.PackageManager,Windows.Management.Deployment,ContentType=WindowsRuntime] | Out-Null
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where { $_.ToString() -eq 'System.Threading.Tasks.Task`1[TResult] AsTask[TResult,TProgress](Windows.Foundation.IAsyncOperationWithProgress`2[TResult,TProgress])'})[0]
$asTaskAsyncOperation =
$asTask.MakeGenericMethod([Windows.Management.Deployment.DeploymentResult],
[Windows.Management.Deployment.DeploymentProgress])
$packageManager = [Windows.Management.Deployment.PackageManager]::new()
$path = $msixJunction + $parentFolder + $packageName # needed if we do the pbisigned.vhd
$path = ([System.Uri]$path).AbsoluteUri
$asyncOperation = $packageManager.StagePackageAsync($path, $null, "StageInPlace")
$task = $asTaskAsyncOperation.Invoke($null, @($asyncOperation))
$task
#endregion