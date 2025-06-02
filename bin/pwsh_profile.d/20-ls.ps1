if (Test-Path alias:ls) {
    Remove-Item alias:ls
}

function ls {
    $showAll = $false
    $longList = $false
    $targets = @()
    $ellipsis = [char]0x2026
    $maxColumnWidth = 30

    foreach ($arg in $args) {
        if ($arg -like '-*') {
            if ($arg -match 'a') { $showAll = $true }
            if ($arg -match 'l') { $longList = $true }
        } else {
            $targets += $arg
        }
    }

    if ($targets.Count -eq 0) {
        $targets = @('.')  # default to current dir
    }

    foreach ($target in $targets) {
        if (-not (Test-Path $target)) {
            Write-Host "ls: cannot access '$target': No such file or directory" -ForegroundColor Red
            continue
        }
        
        # Try treating the path as a directory first
        try {
            $items = Get-ChildItem -Force -LiteralPath $target -ErrorAction Stop
            $isFile = $false
        } catch {
            try {
                # Fall back to treating it as a file
                $items = @(Get-Item -LiteralPath $target -ErrorAction Stop)
                $isFile = $true
            } catch {
                Write-Host "ls: cannot access '$target': $($_.Exception.Message)" -ForegroundColor Red
                continue
            }
        }



        $items = if ($isFile) {
            Get-Item -LiteralPath $target
        } else {
            Get-ChildItem -Force -LiteralPath $target
        }

        $items = @($items)

        if (-not $showAll) {
            $items = $items | Where-Object { $_.Name -notmatch '^\.' -and -not ($_.Attributes -match 'Hidden|System') }
        }

        if ($targets.Count -gt 1) {
            Write-Host ""
            Write-Host ("${target}:") -ForegroundColor Yellow
        }

        $items = @($items)

        if ($longList) {
            $items | Format-Table Mode, LastWriteTime, Length, Name
        } else {
            $longestName = ($items | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
            $maxLen = [math]::Min($longestName + 2, $maxColumnWidth)

            $cols = [math]::Max([math]::Floor($Host.UI.RawUI.WindowSize.Width / $maxLen), 1)

            for ($i = 0; $i -lt $items.Count; $i += $cols) {
                $lineItems = $items[$i..([math]::Min($i + $cols - 1, $items.Count - 1))]
                foreach ($item in $lineItems) {
                    $name = $item.Name
                    if ($name.Length -gt $maxLen - 1) {
                        $name = $name.Substring(0, $maxLen - 2) + $ellipsis
                    }
                    $color = if ($item.PSIsContainer) { 'Cyan' } else { 'White' }
                    Write-Host ($name.PadRight($maxLen)) -NoNewline -ForegroundColor $color
                }
                Write-Host ''
            }
        }
    }
}

