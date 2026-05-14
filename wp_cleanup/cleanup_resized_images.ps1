<#
.SYNOPSIS
    Removes WordPress-style resized image variants when the original exists.

.DESCRIPTION
    Scans a folder (optionally recursively) for image files matching the
    WordPress resized pattern "name-WIDTHxHEIGHT.ext". If the corresponding
    original "name.ext" exists in the same folder, the resized variant is
    deleted. If the original does not exist, the resized file is left alone.

    Supports -WhatIf and -Confirm via SupportsShouldProcess.

.PARAMETER Path
    Folder to scan. Defaults to the current directory.

.PARAMETER Recurse
    Recurse into subdirectories.

.PARAMETER Extensions
    Image extensions to consider. Defaults to jpg, jpeg, png, gif, webp.

.EXAMPLE
    .\Remove-WPResizedImages.ps1 -Path 'C:\backup\uploads' -Recurse -WhatIf

.EXAMPLE
    .\Remove-WPResizedImages.ps1 -Path 'C:\backup\uploads' -Recurse
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Position = 0)]
    [string]$Path = (Get-Location).Path,

    [switch]$Recurse,

    [string[]]$Extensions = @('jpg', 'jpeg', 'png', 'gif', 'webp')
)

if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    throw "Path not found or not a directory: $Path"
}

# Build a regex like: ^(?<base>.+)-(?<w>\d+)x(?<h>\d+)\.(?<ext>jpg|jpeg|png|gif|webp)$
$extAlternation = ($Extensions | ForEach-Object { [regex]::Escape($_) }) -join '|'
$resizedPattern = '^(?<base>.+)-(?<w>\d+)x(?<h>\d+)\.(?<ext>' + $extAlternation + ')$'

# --- 1. Gather all files into an array up front ---
$getParams = @{
    Path  = $Path
    File  = $true
    Force = $true
}
if ($Recurse) { $getParams.Recurse = $true }

$allFiles = @(Get-ChildItem @getParams)
Write-Host "Found $($allFiles.Count) file(s) under '$Path'."

# --- 2. Build a lookup of original files (case-insensitive) for O(1) checks ---
$originals = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($f in $allFiles) {
    if ($f.Name -notmatch $resizedPattern) {
        [void]$originals.Add($f.FullName)
    }
}

# --- 3. Build all resize candidates ---
$candidates = foreach ($f in $allFiles) {
    if ($f.Name -match $resizedPattern) {
        $originalName = "$($Matches['base']).$($Matches['ext'])"
        [pscustomobject]@{
            File         = $f
            FullName     = $f.FullName
            Length       = $f.Length
            OriginalName = $originalName
            OriginalPath = Join-Path -Path $f.DirectoryName -ChildPath $originalName
            HasOriginal  = $originals.Contains((Join-Path -Path $f.DirectoryName -ChildPath $originalName))
        }
    }
}

Write-Host "Identified $($candidates.Count) resized candidate(s)."

# --- 4. Split into the explicit delete list and the orphan list ---
$toDelete = @($candidates | Where-Object { $_.HasOriginal })
$orphans  = @($candidates | Where-Object { -not $_.HasOriginal })

Write-Host "$($toDelete.Count) file(s) queued for deletion, $($orphans.Count) orphan(s) skipped."

# Optional preview when -Verbose is on
if ($VerbosePreference -ne 'SilentlyContinue') {
    $toDelete | Select-Object FullName, OriginalName, Length | Format-Table -AutoSize | Out-String | Write-Host
}

# --- 5. Loop through the delete list and act ---
$deletedCount = 0
$totalBytes   = 0L

foreach ($item in $toDelete) {
    $target = "Delete resized variant (original: $($item.OriginalName))"
    if ($PSCmdlet.ShouldProcess($item.FullName, $target)) {
        try {
            Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
            $deletedCount++
            $totalBytes += $item.Length
        }
        catch {
            Write-Warning "Failed to delete $($item.FullName): $_"
        }
    }
    elseif ($WhatIfPreference) {
        # ShouldProcess already emitted the "What if:" line; just tally.
        $deletedCount++
        $totalBytes += $item.Length
    }
}

$action = if ($WhatIfPreference) { 'Would delete' } else { 'Deleted' }
$mb     = [math]::Round($totalBytes / 1MB, 2)

Write-Host ""
Write-Host "Scanned $($allFiles.Count) file(s); $($candidates.Count) candidate(s); $($toDelete.Count) queued; $($orphans.Count) orphan(s)."
Write-Host "$action $deletedCount file(s), $mb MB."