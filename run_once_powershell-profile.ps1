$target = $PROFILE.CurrentUserCurrentHost
$source = "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"

if (-not (Test-Path (Split-Path $target))) {
    New-Item -ItemType Directory -Path (Split-Path $target) | Out-Null
}

Copy-Item -Path $source -Destination $target -Force

