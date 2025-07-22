$UserStartMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$SystemStartMenu = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"

# We'll store valid entries here
$programs = @()

# Function to parse a .lnk file
function Get-ShortcutInfo {
    param($lnkPath)

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($lnkPath)
    return [PSCustomObject]@{
        name  = [System.IO.Path]::GetFileNameWithoutExtension($lnkPath)
        path  = $shortcut.TargetPath
        icon  = if ($shortcut.IconLocation) { $shortcut.IconLocation } else { $shortcut.TargetPath }
        args  = $shortcut.Arguments
        lnk   = $lnkPath
    }
}

# Combine both Start Menu sources
$startDirs = @($UserStartMenu, $SystemStartMenu)

foreach ($dir in $startDirs) {
    Get-ChildItem -Path $dir -Recurse -File -Filter *.lnk | ForEach-Object {
        $info = Get-ShortcutInfo $_.FullName

        # Skip empty or weird entries
        if (-not $info.Path -or $info.Path -eq '') { return }
        if ($info.Path -match 'uninstall|readme|help|support|www\.' -or
            $info.Name -match 'uninstall|readme|help|support|www\.') { return }

        $programs += $info
    }
}

# Output as JSON
$OutputPath = "$PSScriptRoot\programs.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutputPath, ($programs | ConvertTo-Json -Depth 3), $utf8NoBom)

Write-Host "Saved to $OutputPath"
