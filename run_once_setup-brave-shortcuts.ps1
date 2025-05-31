param (
    [string]$ConfigPath = "$HOME\.local\share\chezmoi\.chezmoidata\braveapps.yaml",
    [string]$ShortcutDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Custom Web Apps",
    [string]$IconCacheDir = "$env:LOCALAPPDATA\BraveShortcutIcons"
)

# Ensure required modules
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
}
Import-Module powershell-yaml

# Create directories if missing
New-Item -ItemType Directory -Force -Path $ShortcutDir | Out-Null
New-Item -ItemType Directory -Force -Path $IconCacheDir | Out-Null

# Load config
$config = ConvertFrom-Yaml (Get-Content $ConfigPath -Raw)
$apps = $config.brave_apps

$WshShell = New-Object -ComObject WScript.Shell

foreach ($app in $apps) {
    $name = $app.name
    $url = $app.url
    $domain = ([uri]$url).Host
    $iconPath = Join-Path $IconCacheDir "$($domain.Replace('.', '_')).ico"
    $shortcutPath = Join-Path $ShortcutDir "$name.lnk"

    # Download favicon if not cached
    if (-not (Test-Path $iconPath)) {
        $faviconUrl = "https://www.google.com/s2/favicons?sz=64&domain=$domain"
        try {
            Invoke-WebRequest -Uri $faviconUrl -OutFile $iconPath -ErrorAction Stop
        } catch {
            Write-Warning "Failed to fetch icon for $name from $faviconUrl"
            $iconPath = $null
        }
    }

    # Create shortcut
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
    $shortcut.Arguments = "--profile-directory=Default --app=$url"
    $shortcut.IconLocation = if ($iconPath) { $iconPath } else { $shortcut.TargetPath }
    $shortcut.Save()

    Write-Output "Created/updated shortcut: $name"
}
