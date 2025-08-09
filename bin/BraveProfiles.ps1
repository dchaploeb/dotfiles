# BraveProfiles.ps1 — minimal, testable helpers for Brave profiles

function Get-BraveUserDataPath {
    Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data"
}

function Get-BraveLocalStatePath {
    Join-Path (Get-BraveUserDataPath) "Local State"
}

function Read-BraveLocalState {
    $p = Get-BraveLocalStatePath
    if (-not (Test-Path $p)) { return $null }
    Get-Content $p -Raw | ConvertFrom-Json
}

function Write-BraveLocalState([object]$obj) {
    $p = Get-BraveLocalStatePath
    $dir = Split-Path $p
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    ($obj | ConvertTo-Json -Depth 20) | Set-Content -Path $p -Encoding UTF8
}

function Ensure-BraveScaffold {
    $ud = Get-BraveUserDataPath
    if (-not (Test-Path $ud)) { New-Item -ItemType Directory -Force $ud | Out-Null }
    $ls = Read-BraveLocalState
    if (-not $ls) {
        $ls = @{ profile = @{ info_cache = @{}; last_used = "Default" } }
        Write-BraveLocalState $ls
    } elseif (-not $ls.profile) {
        $ls | Add-Member -NotePropertyName profile -NotePropertyValue (@{ info_cache = @{}; last_used = "Default" })
        Write-BraveLocalState $ls
    } elseif (-not $ls.profile.info_cache) {
        $ls.profile.info_cache = @{}
        Write-BraveLocalState $ls
    }
    return $ls
}

function Get-BraveProfileDirs {
    if (Test-Path (Get-BraveUserDataPath)) {
        Get-ChildItem -Directory (Get-BraveUserDataPath) | Select-Object -ExpandProperty Name
    } else { @() }
}

function Get-BraveDisplayMap {
    $ls = Read-BraveLocalState
    if (-not $ls -or -not $ls.profile -or -not $ls.profile.info_cache) { return @{} }
    $map = @{}
    foreach ($k in $ls.profile.info_cache.PSObject.Properties.Name) {
        $map[$k] = $ls.profile.info_cache.$k.name
    }
    $map
}

function Resolve-BraveProfileKey([string]$DisplayName) {
    # Reuse existing mapping if present
    $ls = Ensure-BraveScaffold
    foreach ($k in $ls.profile.info_cache.PSObject.Properties.Name) {
        if ($ls.profile.info_cache.$k.name -eq $DisplayName) { return $k }
    }
    # Allocate next free "Profile N"
    $existing = @((Get-BraveProfileDirs)) + @($ls.profile.info_cache.PSObject.Properties.Name)
    $n = 1
    while ($true) {
        $key = "Profile $n"
        if ($existing -notcontains $key) { return $key }
        $n++
    }
}

function Ensure-BraveProfile([string]$DisplayName) {
    $ls = Ensure-BraveScaffold
    $key = Resolve-BraveProfileKey $DisplayName

    # Create directory if missing
    $dir = Join-Path (Get-BraveUserDataPath) $key
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }

    # Ensure mapping exists
    if (-not $ls.profile.info_cache.PSObject.Properties.Name.Contains($key)) {
        $ls.profile.info_cache | Add-Member -NotePropertyName $key -NotePropertyValue (@{ name = $DisplayName })
        Write-BraveLocalState $ls
    } elseif ($ls.profile.info_cache.$key.name -ne $DisplayName) {
        # If key exists but name differs, set it (keeps folder stable)
        $ls.profile.info_cache.$key.name = $DisplayName
        Write-BraveLocalState $ls
    }
    return $key
}

function Show-BraveState {
    $ud = Get-BraveUserDataPath
    $ls = Read-BraveLocalState
    Write-Host "User Data: $ud"
    Write-Host "Dirs: " ([string]::Join(", ", (Get-BraveProfileDirs)))
    if ($ls -and $ls.profile) {
        $pairs = (Get-BraveDisplayMap).GetEnumerator() | ForEach-Object { "$($_.Key)='$($_.Value)'" }
        Write-Host "info_cache: " ([string]::Join(", ", $pairs))
        Write-Host "last_used: $($ls.profile.last_used)"
    } else {
        Write-Host "Local State: <missing or minimal>"
    }
}

# Convenience: delete one mapping (for tests)
function Remove-BraveProfileMapping([string]$Key) {
    $ls = Read-BraveLocalState
    if (-not $ls -or -not $ls.profile -or -not $ls.profile.info_cache) { return }
    if ($ls.profile.info_cache.PSObject.Properties.Name -contains $Key) {
        $ls.profile.info_cache.PSObject.Properties.Remove($Key) | Out-Null
        Write-BraveLocalState $ls
    }
}
