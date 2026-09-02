[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$UserProfilePath = [Environment]::GetFolderPath('UserProfile')
)

$ErrorActionPreference = 'Stop'
$startMarker = '<!-- CODEGRAPH_START -->'
$endMarker = '<!-- CODEGRAPH_END -->'
$authoritativeFile = Join-Path $RepositoryRoot 'global\AGENTS.md'

function Get-CodeGraphBlock {
    param(
        [string]$Content,
        [string]$Source
    )

    $starts = @([regex]::Matches($Content, [regex]::Escape($startMarker)))
    $ends = @([regex]::Matches($Content, [regex]::Escape($endMarker)))
    if ($starts.Count -ne 1 -or $ends.Count -ne 1 -or $ends[0].Index -le $starts[0].Index) {
        throw "Expected one complete CodeGraph block in: $Source"
    }

    $endIndex = $ends[0].Index + $endMarker.Length
    [pscustomobject]@{
        Block = $Content.Substring($starts[0].Index, $endIndex - $starts[0].Index)
        Outside = $Content.Remove($starts[0].Index, $endIndex - $starts[0].Index)
    }
}

$codegraph = Get-Command codegraph -ErrorAction SilentlyContinue
if (-not $codegraph) {
    throw 'CodeGraph is not installed.'
}

& codegraph --version | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'The CodeGraph command is present but unavailable.'
}

$authoritativeContent = [System.IO.File]::ReadAllText($authoritativeFile)
$authoritative = Get-CodeGraphBlock -Content $authoritativeContent -Source $authoritativeFile
$instructionFiles = @(
    Join-Path $UserProfilePath '.codex\AGENTS.md'
    Join-Path $UserProfilePath '.claude\CLAUDE.md'
)

$candidates = @()
$replaceableFiles = @()
foreach ($file in $instructionFiles) {
    if (-not (Test-Path -LiteralPath $file)) {
        continue
    }

    $item = Get-Item -LiteralPath $file -Force
    if ($item.LinkType -eq 'SymbolicLink') {
        continue
    }
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Expected an instruction file or symbolic link: $file"
    }

    $content = [System.IO.File]::ReadAllText($file)
    $candidate = Get-CodeGraphBlock -Content $content -Source $file
    if ($candidate.Outside -ne $authoritative.Outside) {
        throw "Refusing to replace an instruction file with unmanaged content: $file"
    }

    $candidates += $candidate.Block
    $replaceableFiles += $file
}

$distinctCandidates = @($candidates | Select-Object -Unique)
if ($distinctCandidates.Count -gt 1) {
    throw 'Codex and Claude contain different CodeGraph blocks. Resolve the mismatch before syncing.'
}

if ($distinctCandidates.Count -eq 1 -and $distinctCandidates[0] -ne $authoritative.Block) {
    $updatedContent = $authoritativeContent.Replace($authoritative.Block, $distinctCandidates[0])
    [System.IO.File]::WriteAllText(
        $authoritativeFile,
        $updatedContent,
        [System.Text.UTF8Encoding]::new($false)
    )
    Write-Host "Updated CodeGraph block: $authoritativeFile"
}

foreach ($file in $replaceableFiles) {
    Remove-Item -LiteralPath $file -Force
    Write-Host "Removed CodeGraph-rewritten file: $file"
}

& (Join-Path $PSScriptRoot 'install-links.ps1') `
    -RepositoryRoot $RepositoryRoot `
    -UserProfilePath $UserProfilePath
& (Join-Path $PSScriptRoot 'validate-links.ps1') `
    -RepositoryRoot $RepositoryRoot `
    -UserProfilePath $UserProfilePath
