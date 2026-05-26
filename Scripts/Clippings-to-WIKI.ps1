<#
.SYNOPSIS
    Obsidian Clippings to WIKI automation
.DESCRIPTION
    Monitors Clippings/ folder or batch processes existing clippings,
    auto-creates summary notes in WIKI/ with bidirectional backlinks.

    Modes:
      Watch mode (default) : continuously monitors for new clippings
      Batch mode (-Batch)  : processes all unprocessed clippings at once

.PARAMETER VaultPath
    Obsidian Vault root path (default: parent of script's directory)
.PARAMETER Batch
    Switch to batch processing mode
.PARAMETER WatchInterval
    Watch mode check interval in seconds (default: 5)

.EXAMPLE
    .\Scripts\Clippings-to-WIKI.ps1
    .\Scripts\Clippings-to-WIKI.ps1 -Batch
    .\Scripts\Clippings-to-WIKI.ps1 -VaultPath "F:\workspace\Loke\knowledge\Obsidian"
#>

param(
    [string]$VaultPath = "",
    [switch]$Batch = $false,
    [int]$WatchInterval = 5
)

# ========== Path Configuration ==========

if (-not $VaultPath) {
    $VaultPath = (Get-Item $PSScriptRoot).Parent.FullName
}

$ClippingsDir  = Join-Path $VaultPath "Clippings"
$WikiDir       = Join-Path $VaultPath "WIKI"
$LogFile       = Join-Path $VaultPath "Scripts\clippings-wiki.log"

# ========== Helper Functions ==========

function Write-Log {
    param([string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time | $Message" | Out-File -FilePath $LogFile -Encoding utf8 -Append
    Write-Host "$time | $Message"
}

function Get-FrontmatterField {
    param(
        [string]$Frontmatter,
        [string]$FieldName
    )
    if ($Frontmatter -match "$FieldName\s*:\s*""([^""]+)""") {
        return $matches[1]
    } elseif ($Frontmatter -match "$FieldName\s*:\s*'([^']+)'") {
        return $matches[1]
    } elseif ($Frontmatter -match "$FieldName\s*:\s*(.+)") {
        return $matches[1].Trim()
    }
    return ""
}

function Get-SafeFileName {
    param([string]$Name)
    $safe = $Name -replace '[\\/:*?"<>|]', '_'
    $safe = $safe -replace '\s+', ' '
    if ($safe.Length -gt 180) { $safe = $safe.Substring(0, 180) }
    return $safe.Trim()
}

function Get-SummaryFromClipping {
    param([string]$Body)
    if ($Body -match '(?<=#\s*摘要\s*\r?\n)(.*?)(?=\r?\n#\s|\z)' ) {
        return $matches[1].Trim()
    }
    return ""
}

function Test-IsProcessed {
    param([string]$ClippingContent)
    return $ClippingContent -match '\[\[WIKI/'
}

function New-WikiEntry {
    param(
        [string]$ClippingFilePath,
        [string]$ClippingFileName
    )

    Write-Log "Processing: $ClippingFileName"

    $content = Get-Content -Path $ClippingFilePath -Raw -Encoding utf8
    if (-not $content) {
        Write-Log "  [SKIP] Cannot read file"
        return $false
    }

    # Support both LF and CRLF line endings
    if ($content -match '^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)' ) {
        $frontmatter = $matches[1]
        $body        = $matches[2]
    } else {
        Write-Log "  [SKIP] No valid YAML frontmatter"
        return $false
    }

    $title     = Get-FrontmatterField -Frontmatter $frontmatter -FieldName "title"
    $sourceUrl = Get-FrontmatterField -Frontmatter $frontmatter -FieldName "source"

    if (-not $title) { $title = $ClippingFileName -replace '\.md$', '' }

    $summary = Get-SummaryFromClipping -Body $body

    $wikiFileName = $ClippingFileName
    $wikiFilePath = Join-Path $WikiDir $wikiFileName

    if (Test-Path $wikiFilePath) {
        Write-Log "  [SKIP] WIKI already exists: $wikiFileName"
        return $true
    }

    if (-not (Test-Path $WikiDir)) {
        New-Item -ItemType Directory -Path $WikiDir -Force | Out-Null
    }

    $today = Get-Date -Format "yyyy-MM-dd"

    $wikiContent = @"
---
source: "$sourceUrl"
created: $today
tags: []
related:
  - "[[Clippings/$ClippingFileName]]"
---

# $title

> [!abstract] Summary
> $summary

Link: [$title]($sourceUrl)
Full clip: [[Clippings/$ClippingFileName]]

---
> [!info]- Meta
> - **Title**: $title
> - **URL**: $sourceUrl
> - **Clipped**: $today
"@

    try {
        $wikiContent | Out-File -FilePath $wikiFilePath -Encoding utf8
        Write-Log "  [OK] Created WIKI: $wikiFileName"
    } catch {
        Write-Log "  [FAIL] Write WIKI failed: $_"
        return $false
    }

    # Add backlink to the original clipping
    $backlinkMarker = "[[WIKI/$wikiFileName]]"
    $backlinkLine = "**WIKI**: $backlinkMarker"

    if ($content -match '反向链接') {
        # Replace content after the backlink section header
        if ($content -match '(?<=# 反向链接\s*\r?\n).*?(?=\r?\n#|\z)') {
            $newContent = $content -replace '(?<=# 反向链接\s*\r?\n).*?(?=\r?\n#|\z)', $backlinkLine
        } else {
            $newContent = $content -replace '(# 反向链接\s*)', "`$1`n$backlinkLine`n"
        }
    } else {
        # Append backlink section
        $newContent = $content.TrimEnd() + "`r`n`r`n# `u53CD`u5411`u94FE`u63A5`r`n`r`n$backlinkLine"
    }

    try {
        $newContent | Out-File -FilePath $ClippingFilePath -Encoding utf8
        Write-Log "  [OK] Added backlink -> $ClippingFileName"
    } catch {
        Write-Log "  [FAIL] Write backlink failed: $_"
    }

    return $true
}

# ========== Batch Mode ==========

function Invoke-BatchProcess {
    Write-Log "====== Batch mode started ======"

    if (-not (Test-Path $ClippingsDir)) {
        Write-Log "[FAIL] Clippings directory not found: $ClippingsDir"
        return
    }

    $clippings = Get-ChildItem -Path $ClippingsDir -Filter "*.md" | Sort-Object LastWriteTime
    $total = $clippings.Count
    $processed = 0
    $skipped = 0

    Write-Log "Found $total clipping files"

    foreach ($clip in $clippings) {
        $content = Get-Content -Path $clip.FullName -Raw -Encoding utf8 -ErrorAction SilentlyContinue
        if (-not $content) { continue }

        if (Test-IsProcessed -ClippingContent $content) {
            $skipped++
            continue
        }

        $result = New-WikiEntry -ClippingFilePath $clip.FullName -ClippingFileName $clip.Name
        if ($result) { $processed++ }
    }

    Write-Log "====== Batch done: $processed processed, $skipped skipped ======"
}

# ========== Watch Mode ==========

function Invoke-WatchMode {
    Write-Log "====== Watch mode started ======"
    Write-Log "Watching: $ClippingsDir"
    Write-Log "Wiki dir: $WikiDir"
    Write-Log "Interval: ${WatchInterval}s"
    Write-Host ""
    Write-Host "Press Ctrl+C to stop"
    Write-Host ""

    $processedFiles = @{}

    while ($true) {
        if (Test-Path $ClippingsDir) {
            $clippings = Get-ChildItem -Path $ClippingsDir -Filter "*.md" | Sort-Object LastWriteTime

            foreach ($clip in $clippings) {
                if ($processedFiles.ContainsKey($clip.Name)) { continue }

                $size1 = $clip.Length
                Start-Sleep -Seconds 1
                $clip.Refresh()
                $size2 = $clip.Length

                if ($size1 -ne $size2 -or $size1 -eq 0) {
                    continue
                }

                $content = Get-Content -Path $clip.FullName -Raw -Encoding utf8 -ErrorAction SilentlyContinue
                if (-not $content) { continue }

                if (Test-IsProcessed -ClippingContent $content) {
                    $processedFiles[$clip.Name] = $true
                    continue
                }

                $result = New-WikiEntry -ClippingFilePath $clip.FullName -ClippingFileName $clip.Name
                if ($result) {
                    $processedFiles[$clip.Name] = $true
                }
            }
        }

        Start-Sleep -Seconds $WatchInterval
    }
}

# ========== Main ==========

Write-Host ""
Write-Host "=== Obsidian Clippings -> WIKI ==="
Write-Host ""

$logDir = Split-Path $LogFile -Parent
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

if ($Batch) {
    Invoke-BatchProcess
} else {
    Invoke-WatchMode
}
