if (-not (Get-Command Get-PoshStackCount -ErrorAction SilentlyContinue)) {
    oh-my-posh init pwsh | Invoke-Expression
}