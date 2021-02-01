if (-Not (Get-Module Boxstarter.Chocolatey)) {
    . { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force
}

Install-BoxstarterPackage -PackageName https://gist.githubusercontent.com/rucker/6ae2a530c220ea565216261ba3506167/raw/boxstarter.ps1 -DisableReboots

if ($LastExitCode -ne 0) { exit }

$repoRootDir=(git rev-parse --show-toplevel)

Write-Host "Configuring VS Code..."
ForEach($ext in (Get-Content "$repoRootDir/configs/vscode.extensions")) {
    code --install-extension $ext
}

$vsConfigFile="$env:AppData/Code/User/settings.json"
if (Test-Path $vsConfigFile) {
  Move-Item $vsConfigFile ($vsConfigFile + '_' + $(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').bak)
}

New-Item -ItemType symboliclink -path $vsConfigFile -Target $repoRootDir/configs/vscode.user.json

