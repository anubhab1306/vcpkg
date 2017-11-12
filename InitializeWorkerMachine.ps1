[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [String]$PAT,
    [Parameter(Mandatory=$true)]
    [String]$adminPass
)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition

function Recipe
{
    [CmdletBinding()]
    param
    (
        [String]$filepath,
        [ScriptBlock]$Action
    )

    Write-Verbose "Starting recipe for $filepath"

    if(!(Test-Path $filepath))
    {
        Write-Verbose "Invoking recipe for $filepath"
        $Action.Invoke()
    }
    if(!(Test-Path $filepath))
    {
        throw "failed"
    }
}

function Invoke-Executable()
{
    param ( [Parameter(Mandatory=$true)][string]$executable,
                                        [string]$arguments = "",
                                        [switch]$wait)

    Write-Verbose "Executing: ${executable} ${arguments}"
    $process = Start-Process -FilePath $executable -ArgumentList $arguments -PassThru
    if ($wait)
    {
        Wait-Process -InputObject $process
        $ec = $process.ExitCode
        Write-Verbose "Execution terminated with exit code $ec."
    }
}

function UnattendedVSinstall
{
    param(
        [Parameter(Mandatory=$true)][string]$installPath,
        [Parameter(Mandatory=$true)][string]$nickname
    )

    # References
    # https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio
    # https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community#desktop-development-with-c

    $url = "https://aka.ms/vs/15/release/vs_community.exe"
    $filename = "vs_Community.exe"

    Recipe "$scriptsDir\$filename" {
        $url = "https://aka.ms/vs/15/release/vs_community.exe"

        Remove-Item "$filename.part" -Recurse -Force -ErrorAction SilentlyContinue
        Start-BitsTransfer -Source $url -Destination "$filename.part" -ErrorAction Stop
        Move-Item -Path "$filename.part" -Destination $filename -ErrorAction Stop
    }

    Write-Host "Updating VS Installer"
    Invoke-Executable ".\$filename" "--update --quiet --wait --norestart" -wait:$true

    Write-Host "Installing Visual Studio"
    $arguments = ("--installPath $installPath",
    "--add Microsoft.VisualStudio.Workload.NativeDesktop",
    "--add Microsoft.VisualStudio.Workload.Universal",
    "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add Microsoft.VisualStudio.Component.VC.Tools.ARM",
    "--add Microsoft.VisualStudio.Component.VC.Tools.ARM64",
    "--add Microsoft.VisualStudio.Component.VC.ATL",
    "--add Microsoft.VisualStudio.Component.VC.ATLMFC",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.Desktop",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.16299.UWP.Native",
    "--add Microsoft.VisualStudio.ComponentGroup.UWP.VC",
    "--add Microsoft.Component.VC.Runtime.OSSupport",
    "--nickname $nickname",
    "--quiet",
    "--wait",
    "--norestart") -join " "

    Invoke-Executable ".\$filename" "$arguments" -wait:$true
}

powercfg /SETACVALUEINDEX SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0

$filename = "vs_Community.exe"

$unstablePath = "C:\VS2017\Unstable"
$stablePath = "C:\VS2017\Stable"

Recipe $unstablePath {
    UnattendedVSinstall -installPath $unstablePath -nickname "Unstable"
}

Recipe $stablePath {
    UnattendedVSinstall -installPath $stablePath -nickname "Stable"
}

Recipe "C:\vsts\_work" {

    Recipe "C:\vsts" {

        $file = "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip"

        Recipe $file {
            $tmp = "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip.tmp"
            $WC = New-Object System.Net.WebClient
            Remove-Item $tmp
            $WC.DownloadFile("https://github.com/Microsoft/vsts-agent/releases/download/v2.124.0/vsts-agent-win7-x64-2.124.0.zip", $tmp)
            Move-Item $tmp "$scriptsDir\vsts-agent-win7-x64-2.124.0.zip"
        }

        Microsoft.PowerShell.Archive\Expand-Archive -path $file -destinationpath "C:\vsts" -ErrorAction Stop

    }

    Push-Location "C:\vsts"

    & ".\config.cmd" `
    --unattended `
    --url "https://devdiv.visualstudio.com" `
    --auth pat `
    --token $PAT `
    --pool VCLSPool `
    --acceptTeeEula `
    --replace `
    --runAsService `
    --windowsLogonAccount Administrator `
    --windowsLogonPassword $adminPass `
    --work "C:\vsts\_work"

    Pop-Location

}

# Exclude working drive from Windows Defender
Add-MpPreference -ExclusionPath ("C:\")

Restart-Computer