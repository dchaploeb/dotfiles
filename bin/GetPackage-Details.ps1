$installedPackages = Get-WinGetPackage | Where-Object { $_.Source -eq "winget" } | Select-Object -ExpandProperty Id

$results = foreach ($packageId in $installedPackages) {
    $infoRaw = winget show --id $packageId 2>$null

    if (-not [string]::IsNullOrWhiteSpace($infoRaw)) {
        $lines = $infoRaw -split "`r?`n"

        $license  = $lines | Where-Object { $_ -match '^License\s*:' }  | ForEach-Object { ($_ -split ':', 2)[1].Trim() }
        $homepage = $lines | Where-Object { $_ -match '^Homepage\s*:' } | ForEach-Object { ($_ -split ':', 2)[1].Trim() }

        if ($license -or $homepage) {
            [PSCustomObject]@{
                ID       = $packageId
                License  = $license -join ', '
                Homepage = $homepage -join ', '
            }
        }
    }
}

$results | Format-Table -AutoSize
