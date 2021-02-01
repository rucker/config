function LinkConfig {
    Param(
        [Parameter(Mandatory)] [String] $ConfigFile,
        [Parameter(Mandatory)] [String] $LinkTarget
    )
    if (-not (Test-Path $ConfigFile)) {
        New-Item -ItemType symboliclink -path $ConfigFile -Target $LinkTarget | Out-Null
    }
    elseif ((Test-Path $ConfigFile) -and ((Get-Item $ConfigFile).Attributes -notmatch 'ReparsePoint')) {
        Write-Host "Creating backup of config file $ConfigFile..."
        $backupFile = ($ConfigFile + '_' + $(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss') + '.bak')
        Move-Item $ConfigFile $backupFile

        New-Item -ItemType symboliclink -path $ConfigFile -Target $LinkTarget | Out-Null
    }
}

if (-not (Get-Module Boxstarter.Chocolatey)) {
    . { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force
}

Install-BoxstarterPackage -PackageName https://gist.githubusercontent.com/rucker/6ae2a530c220ea565216261ba3506167/raw/boxstarter.ps1 -DisableReboots

if ($LastExitCode -ne 0) { exit }

$repoRootDir=(git rev-parse --show-toplevel)

Write-Host 'Configuring VS Code...'
ForEach($ext in (Get-Content "$repoRootDir\configs\vscode.extensions")) {
    code --install-extension $ext
}

LinkConfig "$env:AppData\Code\User\settings.json" "$repoRootDir\configs\vscode.user.json"

Write-Host 'Updating PowerShell Profile...'
LinkConfig "~\Documents\WindowsPowerShell\profile.ps1" "$repoRootDir\configs\profile.ps1"
