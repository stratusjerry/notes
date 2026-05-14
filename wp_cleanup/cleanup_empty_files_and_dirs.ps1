param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    
    [switch]$WhatIf
)

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Error "Path not found: $Path"
    exit 1
}

# Run
# .\cleanup.ps1 -Path "C:\Users\Foobar\Desktop\Backup" -WhatIf

# Counters
$filesDeleted = 0
$dirsDeleted  = 0
$filesFailed  = 0
$dirsFailed   = 0

# Step 1: Delete zero-byte files
Write-Host "Searching for 0-byte files..." -ForegroundColor Cyan
$emptyFiles = Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -eq 0 }

foreach ($file in $emptyFiles) {
    Write-Host "Removing file: $($file.FullName)" -ForegroundColor Yellow
    try {
        Remove-Item -LiteralPath $file.FullName -Force -WhatIf:$WhatIf -ErrorAction Stop
        $filesDeleted++
    }
    catch {
        Write-Warning "Failed to remove file: $($file.FullName) - $($_.Exception.Message)"
        $filesFailed++
    }
}

# Step 2: Delete empty directories (deepest first, repeated until stable)
Write-Host "Searching for empty directories..." -ForegroundColor Cyan
do {
    $emptyDirs = Get-ChildItem -LiteralPath $Path -Recurse -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { 
            -not (Get-ChildItem -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue) 
        } |
        Sort-Object -Property FullName -Descending

    foreach ($dir in $emptyDirs) {
        Write-Host "Removing directory: $($dir.FullName)" -ForegroundColor Yellow
        try {
            Remove-Item -LiteralPath $dir.FullName -Force -WhatIf:$WhatIf -ErrorAction Stop
            $dirsDeleted++
        }
        catch {
            Write-Warning "Failed to remove directory: $($dir.FullName) - $($_.Exception.Message)"
            $dirsFailed++
        }
    }
} while ($emptyDirs.Count -gt 0 -and -not $WhatIf)

# Summary
Write-Host ""
Write-Host "===== Summary =====" -ForegroundColor Green
if ($WhatIf) {
    Write-Host "Mode: Preview (WhatIf) - nothing was actually deleted" -ForegroundColor Magenta
}
Write-Host ("Files deleted:        {0}" -f $filesDeleted) -ForegroundColor Green
Write-Host ("Directories deleted:  {0}" -f $dirsDeleted) -ForegroundColor Green
if ($filesFailed -gt 0 -or $dirsFailed -gt 0) {
    Write-Host ("Files failed:         {0}" -f $filesFailed) -ForegroundColor Red
    Write-Host ("Directories failed:   {0}" -f $dirsFailed) -ForegroundColor Red
}
Write-Host "Done." -ForegroundColor Green
