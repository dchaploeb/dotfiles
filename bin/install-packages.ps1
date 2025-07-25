# Step 1: List of package IDs we want to install
$requestedPackageIds = @(
    "Brave.Brave",
    "calibre.calibre",
    "dremin.RetroBar",
    "Git.Git",
    "Iterate.Cyberduck",
    "JanDeDobbeleer.OhMyPosh",
    "KeePassXCTeam.KeePassXC",
    "Microsoft.PowerShell",
    "Microsoft.VisualStudioCode",
    "Microsoft.WSL",
    "Notepad++.Notepad++",
    "Obsidian.Obsidian",
    "OpenWhisperSystems.Signal",
    "Proton.ProtonDrive",
    "VideoLAN.VLC",
    "HTTPToolKit.HTTPToolKit",
    "ImageMagick.ImageMagick",
    "Rustlang.Rustup",
    "GitHub.cli"
)

# Step 2: Extract clean IDs from winget list (skip junk)
$installedPackages = Get-WinGetPackage | Where-Object { $_.Source -eq "winget" } | Select-Object -ExpandProperty Id


# Step 3: Install anything missing
function Install-WingetIfMissing($id, $installedPackages) {
    if (-not ($installedPackages -contains $id)) {
        winget install -i $id -e --no-upgrade
    }
}

# Step 4: Loop over requested packages
foreach ($id in $requestedPackageIds) {
    Install-WingetIfMissing $id $installedPackages
}
