function Add-ToPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathToAdd,

        [switch]$SessionOnly
    )

    try {
        # Resolve to absolute path
        $resolvedPath = (Resolve-Path -Path $PathToAdd -ErrorAction Stop).ProviderPath
        # Remove trailing backslash for consistency
        $resolvedPath = $resolvedPath.TrimEnd('\')
    }
    catch {
        Write-Warning "Path '$PathToAdd' could not be resolved. Make sure it exists."
        return
    }

    # ---------------------------
    # Add to current session PATH
    # ---------------------------

    $sessionPaths = $env:PATH -split ';'

    if (-not ($sessionPaths -contains $resolvedPath)) {
        $env:PATH = ($sessionPaths + $resolvedPath) -join ';'
        Write-Output "Added '$resolvedPath' to PATH for this session."
    }
    else {
        Write-Output "Path already exists in session PATH."
    }

    # --------------------------------------
    # Add to permanent User PATH (by default)
    # --------------------------------------

    if (-not $SessionOnly) {
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User") -split ';'

        if (-not ($userPath -contains $resolvedPath)) {
            $newUserPath = ($userPath + $resolvedPath) -join ';'
            [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
            Write-Output "Added '$resolvedPath' to PATH permanently (User scope)."
        }
        else {
            Write-Output "Path already exists in permanent PATH."
        }
    }
}
