if ($null -ne $Host.UI.RawUI) {
    # Likely interactive
    $profileDir = Join-Path $HOME "bin/pwsh_profile.d"

    if (Test-Path $profileDir) {
        Get-ChildItem -Path $profileDir -Filter *.ps1 | Sort-Object Name | ForEach-Object {
            try {
                Write-Host "Running $($_.Name)..."
                . $_.FullName
            } catch {
                Write-Warning "Failed to load $($_.Name): $_"
            }
        }
    }
}
