[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$UserProfilePath = [Environment]::GetFolderPath('UserProfile')
)

$ErrorActionPreference = 'Stop'

$expectedLinks = @(
    @{
        Link = Join-Path $RepositoryRoot 'CLAUDE.md'
        Target = Join-Path $RepositoryRoot 'AGENTS.md'
    },
    @{
        Link = Join-Path $RepositoryRoot 'global\CLAUDE.md'
        Target = Join-Path $RepositoryRoot 'global\AGENTS.md'
    },
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

foreach ($entry in $expectedLinks) {
    $link = [System.IO.Path]::GetFullPath($entry.Link)
    $target = [System.IO.Path]::GetFullPath($entry.Target)

    if (-not (Test-Path -LiteralPath $link)) {
        throw "Missing symbolic link: $link"
    }

    $item = Get-Item -LiteralPath $link -Force
    if ($item.LinkType -ne 'SymbolicLink') {
        throw "Expected a symbolic link: $link"
    }

    $rawTarget = $item.Target | Select-Object -First 1
    $actualTarget = if ([System.IO.Path]::IsPathRooted($rawTarget)) {
        [System.IO.Path]::GetFullPath($rawTarget)
    } else {
        [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $link) $rawTarget))
    }
    if ($actualTarget -ne $target) {
        throw "Unexpected target for ${link}: $actualTarget (expected $target)"
    }

    Write-Host "Valid: $link -> $target"
}
