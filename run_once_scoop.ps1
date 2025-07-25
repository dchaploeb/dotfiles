
scoop bucket add nerd-fonts
scoop install nerd-fonts/SourceCodePro-NF

$sourceFonts = Get-ChildItem "$Env:USERPROFILE\scoop\apps\SourceCodePro-NF\current\*.ttf"

$fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

# Ensure font folder exists
New-Item -ItemType Directory -Path $fontsFolder -Force | Out-Null

foreach ($font in $sourceFonts) {
    $destFont = Join-Path $fontsFolder $font.Name

    $shouldCopy = $true
    if (Test-Path $destFont) {
        # Compare content hashes
        $sourceHash = Get-FileHash $font.FullName -Algorithm SHA256
        $destHash = Get-FileHash $destFont -Algorithm SHA256

        if ($sourceHash.Hash -eq $destHash.Hash) {
            Write-Output "Font already installed and up-to-date: $($font.Name)"
            $shouldCopy = $false
        } else {
            Write-Output "Replacing outdated font: $($font.Name)"
        }
    } else {
        Write-Output "Installing new font: $($font.Name)"
    }

    if ($shouldCopy) {
        Copy-Item -Path $font.FullName -Destination $destFont -Force
    }
}
