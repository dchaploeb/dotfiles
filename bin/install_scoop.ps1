
scoop bucket add nerd-fonts
scoop install nerd-fonts/SourceCodePro-NF
$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
gci -path "$Env:USERPROFILE\scoop\apps\SourceCodePro-NF\current\*.ttf" | % { $fonts.CopyHere($_.fullname) }

$sourceFonts = Get-ChildItem "$Env:USERPROFILE\scoop\apps\SourceCodePro-NF\current\*.ttf"
$fontsFolder = "$env:WINDIR\Fonts"

foreach ($font in $sourceFonts) {
    $destFont = Join-Path $fontsFolder $font.Name

    if (-not (Test-Path $destFont)) {
        Write-Output "Installing font: $($font.Name)"
        $shell = New-Object -ComObject Shell.Application
        $fonts = $shell.Namespace($fontsFolder)
        $fonts.CopyHere($font.FullName)
    } else {
        Write-Output "Font already installed: $($font.Name)"
    }
}
