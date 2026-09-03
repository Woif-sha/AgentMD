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
    [pscustomobject]@{
        Block = $Content.Substring($starts[0].Index, $endIndex - $starts[0].Index)
        Start = $starts[0].Index
        Length = $endIndex - $starts[0].Index
    }
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

$authoritativeFile = Join-Path $RepositoryRoot 'global\AGENTS.md'
$authoritativeContent = [System.IO.File]::ReadAllText($authoritativeFile)
$authoritativeBlock = Get-ManagedBlock -Content $authoritativeContent -Source $authoritativeFile

$entries = @(
    [pscustomobject]@{
        Kind = 'Instruction'
        Link = Join-Path $UserProfilePath '.codex\AGENTS.md'
        Target = $authoritativeFile
    },
    [pscustomobject]@{
        Kind = 'Instruction'
        Link = Join-Path $UserProfilePath '.claude\CLAUDE.md'
        Target = Join-Path $RepositoryRoot 'global\CLAUDE.md'
    }
)

$ruleFiles = Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot 'global\rules') -Filter '*.md' -File
foreach ($hostDirectory in @('.codex', '.claude')) {
    foreach ($ruleFile in $ruleFiles) {
        $entries += [pscustomobject]@{
            Kind = 'Rule'
            Link = Join-Path $UserProfilePath "$hostDirectory\rules\$($ruleFile.Name)"
            Target = $ruleFile.FullName
        }
    }
}

$operations = @()
foreach ($entry in $entries) {
    $target = [System.IO.Path]::GetFullPath($entry.Target)
    $link = [System.IO.Path]::GetFullPath($entry.Link)

    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
        throw "Managed source does not exist: $target"
    }

    $item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) {
        $operations += [pscustomobject]@{ Action = 'CreateLink'; Kind = $entry.Kind; Link = $link; Target = $target }
        continue
    }
    if ($item.PSIsContainer) {
        throw "Expected a file or symbolic link: $link"
    }
    if ($item.LinkType -eq 'SymbolicLink') {
        $existingTarget = Get-LinkTarget -Item $item -Link $link
        if ($existingTarget -ne $target) {
            throw "Refusing to replace an unexpected symbolic link: $link -> $existingTarget"
        }
        $operations += [pscustomobject]@{ Action = 'UnchangedLink'; Kind = $entry.Kind; Link = $link; Target = $target }
        continue
    }

    if ($entry.Kind -eq 'Instruction') {
        $content = [System.IO.File]::ReadAllText($link)
        $managed = Get-ManagedBlock -Content $content -Source $link
        $action = if ($managed.Block -eq $authoritativeBlock.Block) { 'UnchangedCopy' } else { 'UpdateManagedBlock' }
        $operations += [pscustomobject]@{ Action = $action; Kind = $entry.Kind; Link = $link; Target = $target }
        continue
    }

    $sourceContent = [System.IO.File]::ReadAllText($target)
    $installedContent = [System.IO.File]::ReadAllText($link)
    $action = if ($installedContent -eq $sourceContent) { 'UnchangedCopy' } else { 'UpdateRuleCopy' }
    $operations += [pscustomobject]@{ Action = $action; Kind = $entry.Kind; Link = $link; Target = $target }
}

foreach ($operation in $operations) {
    switch ($operation.Action) {
        'CreateLink' {
            $parent = Split-Path -Parent $operation.Link
            if (-not (Test-Path -LiteralPath $parent)) {
                New-Item -ItemType Directory -Path $parent | Out-Null
            }
            New-Item -ItemType SymbolicLink -Path $operation.Link -Target $operation.Target | Out-Null
            Write-Host "Linked: $($operation.Link) -> $($operation.Target)"
        }
        'UpdateManagedBlock' {
            $content = [System.IO.File]::ReadAllText($operation.Link)
            $managed = Get-ManagedBlock -Content $content -Source $operation.Link
            $updated = $content.Remove($managed.Start, $managed.Length).Insert($managed.Start, $authoritativeBlock.Block)
            [System.IO.File]::WriteAllText($operation.Link, $updated, [System.Text.UTF8Encoding]::new($false))
            Write-Host "Updated managed block: $($operation.Link)"
        }
        'UpdateRuleCopy' {
            Copy-Item -LiteralPath $operation.Target -Destination $operation.Link -Force
            Write-Host "Updated managed rule copy: $($operation.Link)"
        }
        'UnchangedLink' {
            Write-Host "Already linked: $($operation.Link) -> $($operation.Target)"
        }
        'UnchangedCopy' {
            Write-Host "Managed copy is current: $($operation.Link)"
        }
    }
}
