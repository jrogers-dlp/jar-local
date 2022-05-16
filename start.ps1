[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $gitDir= "C:\git",
    $psVersion = "7.2.3"
)
# Git directroy Creation
$gitPath = Read-Host -Prompt "Where would you like your git directory? (Default: C:\git)"
if ([string]::IsNullOrWhiteSpace($gitPath)){
    $gitPath = $gitDir
}
if(!(Test-Path $gitPath)){
    Write-Host "Creating Git directory"
    mkdir $gitPath
    cd $gitPath
}else{
    cd $gitPath
}

# PS Install
$reqVer = [version]$psVersion
if($PSVersionTable.PSVersion -ne $reqVer){
    # Docs
    # https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2
    # "https://github.com/PowerShell/PowerShell/releases/download/v7.2.3/PowerShell-7.2.3-win-x64.msi"
    Write-Host "Updating to Powershell $reqVer."
    $psLink = "https://github.com/PowerShell/PowerShell/releases/download/v$psVersion/PowerShell-$psVersion-win-x64.msi"
    $outFile = "PowerShell-$psVersion-win-x64.msi"
    Start-BitsTransfer $psLink ".\$outFile"
    msiexec.exe /package $outFile ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1
}else {
    Write-Host "Latest version of Powershell is installed"
}

# Choco install
try {
    choco -v | Out-Null
    Write-Host "Chocolatey is installed."
}
catch {
    Write-Host "Chocolatey is not installed. Attempting to install."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Dotnet Install
try {
    dotnet --version | Out-Null
}
catch {
    Set-ExecutionPolicy Unrestricted -Force
    Write-Host "dotnet is not installed. Attempting to install sdk."
    $dotnetInstaller = "dotnet-install.ps1"
    if (! (Test-Path ".\$dotnetInstaller")) {
        $dotnetURL  = "https://dot.net/v1/dotnet-install.ps1"
        Start-BitsTransfer $dotnetURL ".\$dotnetInstaller"
    }
    & .\$dotnetInstaller -Channel Current
}

# Install WSL
try {
    wsl -l -v | Out-Null
}
catch {
    Write-Host "WSL is not installed. Attempting to install."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    #wsl --install
}

# Install useful programs
Write-Host "Installing applications via Chocolatey."
Write-Host "WARNING: If output freezes for too long, press ENTER to move it along." -ForegroundColor Red
$applications = @(
    "7zip",
    "git",
    "conemu",
    "keepass",
    "vlc",
    "notepadplusplus",
    "winscp",
    "putty",
    "vscode",
    "irfanview",
    "sumatrapdf",
    "greenshot"
    # "openssl"
    # "unxutils"
    # "sysinternals"
)
$applications | ForEach-Object{choco install -y $_}
refreshenv

# Install Docker
# https://docs.docker.com/get-docker/

# Install AWS CLI
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
aws configure

# Install gcloud
(New-Object Net.WebClient).DownloadFile("https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe", "$env:Temp\GoogleCloudSDKInstaller.exe")
& $env:Temp\GoogleCloudSDKInstaller.exe

# Install PS Modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module posh-git, oh-my-posh, psake -Force


# Update PS Profile
$myprof = @"
`$githome = '$gitDir'
oh-my-posh --init --shell pwsh --config `$env:POSH_THEMES_PATH/hunk.omp.json | Invoke-Expression
set-location `$gitHome
"@
New-Item -Path $profile -ItemType file -Value $myprof

