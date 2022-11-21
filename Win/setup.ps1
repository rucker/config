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

# Note: the bash command below will fail if e.g. WSL is installed but has not been launched for the first time.
# The error message will state: Windows Subsystem for Linux has no installed distributions.
if (-Not (Test-Path $HOME\repos\dotfiles)) {
  Write-Host Setting up dotfiles...
  if (-Not (Test-Path $HOME\repos)) {
    mkdir $HOME\repos
  }
  if (-Not (Test-Path $HOME\repos\dotfiles)) {
    git clone https://github.com/rucker/dotfiles.git $HOME\repos\dotfiles
  }
}

& 'C:\Program Files\Git\bin\bash.exe' -c '$HOME/repos/dotfiles/dotfiles.sh --install'

$dotfilesExitCode = $LastExitCode
if ($dotfilesExitCode -ne 0) {
    Exit $dotfilesExitCode
 }

Write-Host Dotfiles repos are ready. Remember to configure your _local files and run dotfiles script

if (-not (Get-Module Boxstarter.Chocolatey)) {
    . { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force
}

Install-BoxstarterPackage -PackageName https://gist.githubusercontent.com/rucker/6ae2a530c220ea565216261ba3506167/raw/boxstarter.ps1 -DisableReboots

if ($LastExitCode -ne 0) { exit }

Enable-MicrosoftUpdate

$repoRootDir=(git rev-parse --show-toplevel)

Write-Host 'Configuring VS Code...'
ForEach($ext in (Get-Content "$repoRootDir\configs\vscode.extensions")) {
    code --install-extension $ext
}

LinkConfig "$env:AppData\Code\User\settings.json" "$repoRootDir\configs\vscode.user.json"

Write-Host 'Updating PowerShell Profile...'
LinkConfig "~\Documents\WindowsPowerShell\profile.ps1" "$repoRootDir\configs\profile.ps1"
