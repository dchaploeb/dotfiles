# this doesn't work, so I'm essentially commenting it out
# Ensure the module is installed and imported
if (-not (Get-Module -ListAvailable -Name Microsoft.WinGet.Client)) {
    try {
        # Make sure NuGet provider is available
        if (-not (Get-PackageProvider -ListAvailable -Name NuGet)) {
            Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
        }

        # Install module quietly
        Install-Module -Name Microsoft.WinGet.Client -Scope CurrentUser -Force -Confirm:$false
    } catch {
        Write-Error "Failed to install Microsoft.WinGet.Client: $_"
    }
}


# Import it if needed
Import-Module Microsoft.WinGet.Client -ErrorAction SilentlyContinue

