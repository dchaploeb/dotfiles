Add-Type -AssemblyName System.Drawing

# Paths
$UserStartMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$SystemStartMenu = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
$startDirs = @($UserStartMenu, $SystemStartMenu)

$skinName = 'Startmeter'
$skinFolder = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "Rainmeter\Skins\$skinName"
$resourceFolder = Join-Path $skinFolder "@Resources"
$iconFolder = Join-Path $resourceFolder "Icons"
$iniPath = Join-Path $skinFolder "Startmeter.ini"

# Create needed folders
New-Item -ItemType Directory -Force -Path $iconFolder | Out-Null

# Extract info from shortcuts
function Get-ShortcutInfo {
    param($lnkPath)
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($lnkPath)
    return [PSCustomObject]@{
        name = [System.IO.Path]::GetFileNameWithoutExtension($lnkPath)
        path = $shortcut.TargetPath
        icon = if ($shortcut.IconLocation) { $shortcut.IconLocation.Split(',')[0] } else { $shortcut.TargetPath }
    }
}

# Extract .ico/.exe icons to .png files
function Extract-IconPng {
    param($sourcePath, $targetPath)
    try {
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($sourcePath)
        if ($icon -ne $null) {
            $bmp = $icon.ToBitmap()
            $bmp.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $bmp.Dispose()
        }
    }
    catch {}
}

# Collect valid programs
$programs = @()
foreach ($dir in $startDirs) {
    Get-ChildItem -Path $dir -Recurse -File -Filter *.lnk | ForEach-Object {
        $info = Get-ShortcutInfo $_.FullName
        if (-not $info.path -or $info.path -eq '') { return }
        if ($info.path -match 'uninstall|readme|help|support|www\.' -or
            $info.name -match 'uninstall|readme|help|support|www\.') { return }
        $programs += $info
    }
}

# Start writing the .ini
$ini = @"
[Rainmeter]
Update=1000
DynamicWindowSize=1
AccurateText=1
"@

# Add one icon + one text meter per program
$y = 10
$i = 1
foreach ($p in $programs) {
    $label = $p.name -replace '\[|\]', ''
    $exePath = $p.path -replace '"', '""'
    $iconFile = "Program$i.png"
    $iconPath = Join-Path $iconFolder $iconFile

    Extract-IconPng -sourcePath $p.icon -targetPath $iconPath

    $ini += @"

[ProgramIcon$i]
Meter=Image
ImageName=#@#Icons\$iconFile
X=10
Y=$y
W=16
H=16

[ProgramText$i]
Meter=String
Text=$label
X=32
Y=$y
FontSize=12
LeftMouseUpAction=["cmd.exe" "/c start \"\" \"${exePath}\""]
AntiAlias=1
"@
    $y += 24
    $i++
}

# Write the .ini file
New-Item -ItemType Directory -Force -Path $skinFolder | Out-Null
$ini | Set-Content -Encoding UTF8 -Path $iniPath

# Reload Rainmeter skin
Start-Process "$env:ProgramFiles\Rainmeter\Rainmeter.exe" -ArgumentList "!RefreshStartmeter"


Write-Host "Generated Startmeter.ini with $($i - 1) entries"
