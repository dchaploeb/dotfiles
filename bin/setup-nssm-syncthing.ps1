<# 
.SYNOPSIS
  Install/refresh a Syncthing Windows service using NSSM, with sane defaults.

.DESCRIPTION
  - Finds syncthing.exe from the winget shim OR a provided -ExePath
  - Installs/updates an NSSM service (default name "Syncthing")
  - Runs as your user if you pass -RunAsCurrentUser (you'll be prompted for your password)
  - Logs stdout/stderr to %LOCALAPPDATA%\Syncthing\logs with rotation
  - Optionally opens firewall ports (22000 TCP/UDP, 21027 UDP) with -OpenFirewall
  - Idempotent: re-running updates settings

.EXAMPLES
  .\syncthing-nssm-setup.ps1 -StartNow -RunAsCurrentUser -OpenFirewall
  .\syncthing-nssm-setup.ps1 -ServiceName Syncthing-ARM -ExePath "C:\path\syncthing.exe"

#>

param(
  [string]$ServiceName = "Syncthing",
  [string]$HomeDir = "$env:LOCALAPPDATA\Syncthing",
  [string]$ExePath,
  [switch]$RunAsCurrentUser,
  [switch]$StartNow,
  [switch]$OpenFirewall
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-SyncthingExe {
  param([string]$Override)

  if ($Override) {
    if (Test-Path $Override) { return (Resolve-Path $Override).Path }
    throw "Provided -ExePath not found: $Override"
  }

  $candidates = @()

  # 1) Winget shim target
  $shim = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\syncthing.exe"
  if (Test-Path $shim) {
    try {
      $target = (Get-Item $shim).Target
      if ($target -and (Test-Path $target)) { $candidates += $target }
    } catch {}
  }

  # 2) Common user install
  $candidates += "$env:LOCALAPPDATA\Programs\Syncthing\syncthing.exe"

  # 3) Winget package cache (per-user)
  $pkgRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
  if (Test-Path $pkgRoot) {
    $found = Get-ChildItem -Path $pkgRoot -Directory -Filter "Syncthing.Syncthing_*" -ErrorAction SilentlyContinue |
      ForEach-Object {
        Get-ChildItem -Path $_.FullName -Filter syncthing.exe -Recurse -ErrorAction SilentlyContinue
      } | Select-Object -First 1
    if ($found) { $candidates += $found.FullName }
  }

  foreach ($c in $candidates) {
    if ($c -and (Test-Path $c)) { return (Resolve-Path $c).Path }
  }
  throw "Could not locate syncthing.exe. Provide -ExePath explicitly."
}

function Ensure-Nssm {
  $nssm = Get-Command nssm -ErrorAction SilentlyContinue
  if ($nssm) { return $nssm.Source }
  Write-Host "NSSM not found in PATH. Attempting installation via winget..." -ForegroundColor Yellow
  # Try to install NSSM silently via winget
  try {
    winget install -e --id NSSM.NSSM --accept-source-agreements --accept-package-agreements --silent | Out-Null
  } catch {
    Write-Warning "winget install NSSM failed. Please install NSSM manually and re-run."
    throw
  }
  $nssm = Get-Command nssm -ErrorAction SilentlyContinue
  if (-not $nssm) { throw "NSSM still not available after install. Check your PATH/shell." }
  return $nssm.Source
}

function Install-Or-Update-Service {
  param(
    [string]$SvcName,
    [string]$Exe,
    [string]$WorkDir,
    [string]$HomePath,
    [switch]$RunAsUserSwitch
  )

  $exists = (Get-Service -Name $SvcName -ErrorAction SilentlyContinue) -ne $null
  if (-not $exists) { & nssm install $SvcName $Exe | Out-Null }
  else { & nssm set $SvcName Application $Exe | Out-Null }

  & nssm set $SvcName AppDirectory $WorkDir | Out-Null
  & nssm set $SvcName AppParameters "-no-console -no-browser -home `"$HomePath`"" | Out-Null
  & nssm set $SvcName Start SERVICE_AUTO_START | Out-Null

  $logDir = Join-Path $HomePath "logs"
  if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
  & nssm set $SvcName AppStdout (Join-Path $logDir "syncthing.out.log") | Out-Null
  & nssm set $SvcName AppStderr (Join-Path $logDir "syncthing.err.log") | Out-Null
  & nssm set $SvcName AppRotateFiles 1 | Out-Null
  & nssm set $SvcName AppRotateOnline 1 | Out-Null
  & nssm set $SvcName AppRotateBytes 10485760 | Out-Null

  if ($RunAsUserSwitch) {
    $user = ".\$env:USERNAME"
    $secure = Read-Host -AsSecureString -Prompt "Enter password for $user (used to run the service)"
    $plain = (New-Object System.Net.NetworkCredential("", $secure)).Password
    & nssm set $SvcName ObjectName $user $plain | Out-Null
  } else {
    Write-Host "Service will run as LocalSystem by default. Pass -RunAsCurrentUser to run as your user." -ForegroundColor Yellow
  }
}

function Open-FirewallPorts {
  # Add rules if missing; ignore errors if already exist
  $rules = @(
    @{ Name="Syncthing TCP 22000"; Protocol="TCP"; Port=22000 },
    @{ Name="Syncthing UDP 22000"; Protocol="UDP"; Port=22000 },
    @{ Name="Syncthing Discovery 21027 UDP"; Protocol="UDP"; Port=21027 }
  )
  foreach ($r in $rules) {
    if (-not (Get-NetFirewallRule -DisplayName $r.Name -ErrorAction SilentlyContinue)) {
      New-NetFirewallRule -DisplayName $r.Name -Direction Inbound -Protocol $r.Protocol -LocalPort $r.Port -Action Allow | Out-Null
    }
  }
}

# ---- Main ----
$nssmPath = Ensure-Nssm
$syncthingExe = Resolve-SyncthingExe -Override:$ExePath
$workDir = Split-Path $syncthingExe

if (-not (Test-Path $HomeDir)) { New-Item -ItemType Directory -Path $HomeDir | Out-Null }

Install-Or-Update-Service -SvcName $ServiceName -Exe $syncthingExe -WorkDir $workDir -Home $HomeDir -RunAsUserSwitch:$RunAsCurrentUser

if ($OpenFirewall) { Open-FirewallPorts }

if ($StartNow) {
  try { 
    if ((Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).Status -eq 'Running') {
      Restart-Service -Name $ServiceName -Force -ErrorAction Stop
    } else {
      Start-Service -Name $ServiceName -ErrorAction Stop
    }
  } catch {
    Write-Warning "Couldn't start/restart the service automatically: $_"
    Write-Host "You can start it later with: nssm start $ServiceName"
  }
}

Write-Host "Done. Web UI: http://127.0.0.1:8384" -ForegroundColor Green
