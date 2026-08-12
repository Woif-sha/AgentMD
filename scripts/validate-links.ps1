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
        Link = Join-Path $UserProfilePath '.claude\CLAUDE.md'
        Target = Join-Path $RepositoryRoot 'global\CLAUDE.md'
    }
)

$ruleFiles = Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot 'global\rules') -Filter '*.md' -File
foreach ($hostDirectory in @('.codex', '.claude')) {
    foreach ($ruleFile in $ruleFiles) {
        $expectedLinks += @{
            Link = Join-Path $UserProfilePath "$hostDirectory\rules\$($ruleFile.Name)"
            Target = $ruleFile.FullName
        }
    }
}

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

$markdownFiles = Get-ChildItem -LiteralPath $RepositoryRoot -Filter '*.md' -File -Recurse
$inlineLinkPattern = [regex]'!?(?:\[[^\]]*\])\((?:<(?<angle>[^>]+)>|(?<plain>[^\s\)]+))(?:\s+["''][^"'']*["''])?\)'
$referenceLinkPattern = [regex]'^\s{0,3}\[[^\]]+\]:\s*(?:<(?<angle>[^>]+)>|(?<plain>\S+))'

foreach ($markdownFile in $markdownFiles) {
    $inFence = $false
    $lineNumber = 0

    foreach ($line in Get-Content -LiteralPath $markdownFile.FullName) {
        $lineNumber++
        if ($line -match '^\s*(```|~~~)') {
            $inFence = -not $inFence
            continue
        }
        if ($inFence) {
            continue
        }

        $matches = @($inlineLinkPattern.Matches($line))
        $referenceMatch = $referenceLinkPattern.Match($line)
        if ($referenceMatch.Success) {
            $matches += $referenceMatch
        }

        foreach ($match in $matches) {
            $destination = if ($match.Groups['angle'].Success) {
                $match.Groups['angle'].Value
            } else {
                $match.Groups['plain'].Value
            }

            if ($destination.StartsWith('#') -or $destination -match '^[a-z][a-z0-9+.-]*:') {
                continue
            }

            $pathPart = ($destination -split '[?#]', 2)[0]
            if ([string]::IsNullOrEmpty($pathPart)) {
                continue
            }

            $decodedPath = [Uri]::UnescapeDataString($pathPart)
            $resolvedPath = [System.IO.Path]::GetFullPath((Join-Path $markdownFile.DirectoryName $decodedPath))
            if (-not (Test-Path -LiteralPath $resolvedPath)) {
                $relativeSource = [System.IO.Path]::GetRelativePath($RepositoryRoot, $markdownFile.FullName)
                throw "Broken Markdown link in ${relativeSource}:${lineNumber}: $destination"
            }
        }
    }
}

Write-Host "Valid: local Markdown links in $($markdownFiles.Count) files"
