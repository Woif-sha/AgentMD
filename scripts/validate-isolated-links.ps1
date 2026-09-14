[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

function Remove-ValidationProfile {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $profile = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -eq $profile) {
        return
    }
    if (-not $profile.PSIsContainer -or $profile.LinkType -eq 'SymbolicLink') {
        throw "Refusing to clean an unexpected validation path: $Path"
    }

    # Delete files through the file API so a broken or external symlink is
    # removed as a link object rather than followed to its target.
    $items = @(Get-ChildItem -LiteralPath $Path -Recurse -Force)
    foreach ($item in ($items | Where-Object { -not $_.PSIsContainer } | Sort-Object { $_.FullName.Length } -Descending)) {
        [System.IO.File]::Delete($item.FullName)
    }

    foreach ($directory in ($items | Where-Object { $_.PSIsContainer } | Sort-Object { $_.FullName.Length } -Descending)) {
        [System.IO.Directory]::Delete($directory.FullName, $false)
    }
    [System.IO.Directory]::Delete($Path, $false)
}

$validationRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('agentmd-validation-' + [guid]::NewGuid().ToString('N'))
$validationRepository = Join-Path $validationRoot 'repository'
$validationProfile = Join-Path $validationRoot 'profile'

New-Item -ItemType Directory -Path $validationRoot | Out-Null

try {
    New-Item -ItemType Directory -Path (Join-Path $validationRepository 'global\rules') -Force | Out-Null
    New-Item -ItemType Directory -Path $validationProfile -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $RepositoryRoot 'AGENTS.md') -Destination (Join-Path $validationRepository 'AGENTS.md')
    Copy-Item -LiteralPath (Join-Path $RepositoryRoot 'global\AGENTS.md') -Destination (Join-Path $validationRepository 'global\AGENTS.md')
    Get-ChildItem -LiteralPath (Join-Path $RepositoryRoot 'global\rules') -Filter '*.md' -File |
        Copy-Item -Destination (Join-Path $validationRepository 'global\rules')
    New-Item -ItemType SymbolicLink -Path (Join-Path $validationRepository 'CLAUDE.md') -Target 'AGENTS.md' | Out-Null
    New-Item -ItemType SymbolicLink -Path (Join-Path $validationRepository 'global\CLAUDE.md') -Target 'AGENTS.md' | Out-Null

    & (Join-Path $PSScriptRoot 'install-links.ps1') `
        -RepositoryRoot $validationRepository `
        -UserProfilePath $validationProfile
    & (Join-Path $PSScriptRoot 'validate-links.ps1') `
        -RepositoryRoot $validationRepository `
        -UserProfilePath $validationProfile
}
finally {
    Remove-ValidationProfile -Path $validationRoot
}
