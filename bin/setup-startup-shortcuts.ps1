$startup = [Environment]::GetFolderPath('Startup')
if (-not (Test-Path $startup)) { New-Item -ItemType Directory -Force $startup | Out-Null }

function New-StartupShortcut {
    param([string]$ExePath, [string]$Name)

    $lnk = Join-Path ([Environment]::GetFolderPath('Startup')) ($Name + '.lnk')

    if (-not (Test-Path $ExePath)) {
        Write-Host ("SKIP {0}: exe not found: {1}" -f $Name, $ExePath)
        return
    }
    if (Test-Path $lnk) {
        Write-Host ("OK {0}: shortcut exists" -f $Name)
        return
    }

    try {
        $shell = New-Object -ComObject WScript.Shell
        $sc = $shell.CreateShortcut($lnk)
        $sc.TargetPath       = $ExePath
        $sc.WorkingDirectory = Split-Path $ExePath
        $sc.IconLocation     = "$ExePath,0"
        $sc.Save()
        Write-Host ("CREATED {0}: {1}" -f $Name, $lnk)
        Start-Process -FilePath $ExePath
        Write-Host ("LAUNCHED {0}" -f $Name)
    } catch {
        Write-Warning ("FAILED {0}: {1}" -f $Name, $_.Exception.Message)
    }
}


# Adjust these if needed:
$retro = "$env:LOCALAPPDATA\Programs\RetroBar\RetroBar.exe"
$yasb  = "$env:ProgramFiles\yasb\yasb.exe"

New-StartupShortcut -ExePath $retro -Name 'RetroBar'
New-StartupShortcut -ExePath $yasb  -Name 'yasb'

Get-ChildItem $startup
