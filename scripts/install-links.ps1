[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$UserProfilePath = [Environment]::GetFolderPath('UserProfile')
)

$ErrorActionPreference = 'Stop'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = Join-Path $UserProfilePath ".agentmd-backups\$timestamp"

$links = @(
    @{
        Link = Join-Path $UserProfilePath '.codex\AGENTS.md'
        Target = Join-Path $RepositoryRoot 'global\AGENTS.md'
    },
    @{
        Link = Join-Path $UserProfilePath '.codex\rules\git-delivery.md'
        Target = Join-Path $RepositoryRoot 'global\rules\git-delivery.md'
    },
    @{
        Link = Join-Path $UserProfilePath '.claude\CLAUDE.md'
        Target = Join-Path $RepositoryRoot 'global\CLAUDE.md'
    }
)

foreach ($entry in $links) {
    $target = [System.IO.Path]::GetFullPath($entry.Target)
    $link = [System.IO.Path]::GetFullPath($entry.Link)

    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
        throw "Link target does not exist: $target"
    }

    $parent = Split-Path -Parent $link
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }

    if (Test-Path -LiteralPath $link) {
        $existing = Get-Item -LiteralPath $link -Force
        $existingTarget = if ($existing.LinkType -eq 'SymbolicLink') {
            [System.IO.Path]::GetFullPath(($existing.Target | Select-Object -First 1))
        }

        if ($existingTarget -eq $target) {
            Write-Host "Already linked: $link -> $target"
            continue
        }

        $relativePath = [System.IO.Path]::GetRelativePath($UserProfilePath, $link)
        $backupPath = Join-Path $backupRoot $relativePath
        $backupParent = Split-Path -Parent $backupPath
        New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
        Copy-Item -LiteralPath $link -Destination $backupPath
        Remove-Item -LiteralPath $link -Force
        Write-Host "Backed up: $link -> $backupPath"
    }

    New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
    Write-Host "Linked: $link -> $target"
}
