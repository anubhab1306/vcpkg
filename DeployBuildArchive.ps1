[CmdletBinding()]
param(
    [string]$tfsBranch,
    [Parameter(ParameterSetName='SetLatest')]
    [switch]$latest,
    [Parameter(ParameterSetName='SetBuildNumber')]
    [string]$buildNumber
)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
. "$scriptsDir\VcpkgPowershellUtils.ps1"

$buildArchiveFolderRoot = "\\vcpkg-000\General\CustomBuilds"
if ($latest)
{
    $branchBuildArchives = Get-ChildItem $buildArchiveFolderRoot | Where-Object {$_.Name -match "^$tfsBranch"}
    if ($branchBuildArchives.count -eq 0)
    {
        Write-Error "Count not find build archives for branch $tfsBranch in: $buildArchiveFolderRoot"
        throw;
    }

    $buildArchive = ($branchBuildArchives | Sort-object Name -Descending).fullname[0]
}
else
{
    $buildArchive = "$buildArchiveFolderRoot\$tfsBranch-$buildNumber"
}

if (!(Test-Path $buildArchive))
{
    Write-Error "$buildArchive was not found"
    throw;
}

Write-Host "Deploying $buildArchive"

$deploymentRoot = "C:\VS2017\Unstable\VC\Tools\MSVC\"
$msvcVersion = "14.11.25503" # We should be smarter about finding this value. Also, what if multiples exist (if that is possible)?

Write-Host "Cleaning-up $deploymentRoot..."
vcpkgRemoveItem $deploymentRoot
vcpkgCreateDirectoryIfNotExists $deploymentRoot
Write-Host "Cleaning-up $deploymentRoot... done."

Write-Host "Copying $buildArchive..."
$buildArchiveName = Split-Path $buildArchive -leaf
$tempBuildArchive = "$deploymentRoot\$buildArchiveName"
Copy-Item $buildArchive -Destination $tempBuildArchive
Write-Host "Copying $buildArchive... done."

$deploymentPath = "$deploymentRoot\$msvcVersion"
Write-Host "Deployment path: $deploymentPath"
Write-Host "Extracting 7z..."
$time7z = Measure-Command {& .\7za.exe x $tempBuildArchive -o"$deploymentPath" -y}
$formattedTime7z = vcpkgFormatElapsedTime $time7z
Write-Host "Extracting 7z... done. Time Taken: $formattedTime7z seconds"

