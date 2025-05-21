
$pwshProfile = Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$winProfileDir = Join-Path $HOME "Documents\WindowsPowerShell"
$winProfile = Join-Path $winProfileDir "Microsoft.PowerShell_profile.ps1"

if (-Not (Test-Path $winProfileDir)) {
    New-Item -ItemType Directory -Path $winProfileDir | Out-Null
}

if (-Not (Test-Path $winProfile)) {
    Write-Host "Creating a forwarding profile script for Windows PowerShell..."
    Set-Content -Path $winProfile -Value ". `"$pwshProfile`"" -Encoding UTF8
} else {
    Write-Host "WindowsPowerShell profile already exists at $winProfile"
}
