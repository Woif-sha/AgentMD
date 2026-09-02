[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$UserProfilePath = [Environment]::GetFolderPath('UserProfile')
)

$ErrorActionPreference = 'Stop'
$startMarker = '<!-- AGENTMD_START -->'
$endMarker = '<!-- AGENTMD_END -->'

function Get-ManagedBlock {
    param(
        [string]$Content,
        [string]$Source
    )

    $starts = @([regex]::Matches($Content, [regex]::Escape($startMarker)))
    $ends = @([regex]::Matches($Content, [regex]::Escape($endMarker)))
    if ($starts.Count -ne 1 -or $ends.Count -ne 1 -or $ends[0].Index -le $starts[0].Index) {
        throw "Expected one complete AgentMD managed block in: $Source"
    }

    $endIndex = $ends[0].Index + $endMarker.Length
    return $Content.Substring($starts[0].Index, $endIndex - $starts[0].Index)
}

function Get-LinkTarget {
    param(
        [System.IO.FileSystemInfo]$Item,
        [string]$Link
    )

    $rawTarget = $Item.Target | Select-Object -First 1
    if ([System.IO.Path]::IsPathRooted($rawTarget)) {
        return [System.IO.Path]::GetFullPath($rawTarget)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $Link) $rawTarget))
}

function Assert-RepositoryLink {
    param(
        [string]$Link,
        [string]$Target
    )

    $linkPath = [System.IO.Path]::GetFullPath($Link)
    $targetPath = [System.IO.Path]::GetFullPath($Target)
    $item = Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
    if ($null -eq $item -or $item.LinkType -ne 'SymbolicLink') {
        throw "Expected a symbolic link: $linkPath"
    }
    $actualTarget = Get-LinkTarget -Item $item -Link $linkPath
    if ($actualTarget -ne $targetPath) {
        throw "Unexpected target for ${linkPath}: $actualTarget (expected $targetPath)"
    }
    Write-Host "Valid repository link: $linkPath -> $targetPath"
}

function Assert-InstalledFile {
    param(
        [string]$Kind,
        [string]$Link,
        [string]$Target,
        [string]$AuthoritativeBlock
    )

    $linkPath = [System.IO.Path]::GetFullPath($Link)
    $targetPath = [System.IO.Path]::GetFullPath($Target)
    $item = Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
    if ($null -eq $item -or $item.PSIsContainer) {
        throw "Expected an installed file or symbolic link: $linkPath"
    }

    if ($item.LinkType -eq 'SymbolicLink') {
        $actualTarget = Get-LinkTarget -Item $item -Link $linkPath
        if ($actualTarget -ne $targetPath) {
            throw "Unexpected target for ${linkPath}: $actualTarget (expected $targetPath)"
        }
        Write-Host "Valid linked ${Kind}: $linkPath -> $targetPath"
        return
    }

    $installedContent = [System.IO.File]::ReadAllText($linkPath)
    if ($Kind -eq 'instruction') {
        $installedBlock = Get-ManagedBlock -Content $installedContent -Source $linkPath
        if ($installedBlock -ne $AuthoritativeBlock) {
            throw "Outdated AgentMD managed block: $linkPath"
        }
        Write-Host "Valid managed instruction copy: $linkPath"
        return
    }

    $sourceContent = [System.IO.File]::ReadAllText($targetPath)
    if ($installedContent -ne $sourceContent) {
        throw "Outdated managed rule copy: $linkPath"
    }
    Write-Host "Valid managed rule copy: $linkPath"
}

$authoritativeFile = Join-Path $RepositoryRoot 'global\AGENTS.md'
$authoritativeContent = [System.IO.File]::ReadAllText($authoritativeFile)
$authoritativeBlock = Get-ManagedBlock -Content $authoritativeContent -Source $authoritativeFile
$projectInstructionFile = Join-Path $RepositoryRoot 'AGENTS.md'
$projectInstructionContent = [System.IO.File]::ReadAllText($projectInstructionFile)
$null = Get-ManagedBlock -Content $projectInstructionContent -Source $projectInstructionFile

Assert-RepositoryLink `
    -Link (Join-Path $RepositoryRoot 'CLAUDE.md') `
    -Target (Join-Path $RepositoryRoot 'AGENTS.md')
Assert-RepositoryLink `
    -Link (Join-Path $RepositoryRoot 'global\CLAUDE.md') `
    -Target $authoritativeFile

$installedFiles = @(
    [pscustomobject]@{
        Kind = 'instruction'
        Link = Join-Path $UserProfilePath '.codex\AGENTS.md'
        Target = $authoritativeFile
    },
    [pscustomobject]@{
        Kind = 'instruction'
        Link = Join-Path $UserProfilePath '.claude\CLAUDE.md'
        Target = Join-Path $RepositoryRoot 'global\CLAUDE.md'
    }
)

$ruleFiles = Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot 'global\rules') -Filter '*.md' -File
foreach ($hostDirectory in @('.codex', '.claude')) {
    foreach ($ruleFile in $ruleFiles) {
        $installedFiles += [pscustomobject]@{
            Kind = 'rule'
            Link = Join-Path $UserProfilePath "$hostDirectory\rules\$($ruleFile.Name)"
            Target = $ruleFile.FullName
        }
    }
}

foreach ($entry in $installedFiles) {
    Assert-InstalledFile `
        -Kind $entry.Kind `
        -Link $entry.Link `
        -Target $entry.Target `
        -AuthoritativeBlock $authoritativeBlock
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

        $linkMatches = @($inlineLinkPattern.Matches($line))
        $referenceMatch = $referenceLinkPattern.Match($line)
        if ($referenceMatch.Success) {
            $linkMatches += $referenceMatch
        }

        foreach ($match in $linkMatches) {
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

Write-Host "Valid local Markdown links in $($markdownFiles.Count) files"
