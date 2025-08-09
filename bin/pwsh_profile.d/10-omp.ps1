$omp = Get-Command oh-my-posh -ErrorAction SilentlyContinue
if (-not $omp) {
$candidates = @(
    "$env:LOCALAPPDATA\Programs\oh-my-posh\bin\oh-my-posh.exe",
    "$env:ProgramFiles\oh-my-posh\bin\oh-my-posh.exe"
) | Where-Object { Test-Path $_ }
if ($candidates) {
    $bin = Split-Path -Parent $candidates[0]
    if (-not ($env:Path -split ';' | Where-Object { $_ -eq $bin })) {
    $env:Path = "$bin;$env:Path"
    }
}
}
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$HOME\.omp.json" | Invoke-Expression
}
