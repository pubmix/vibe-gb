$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $projectRoot
function Find-GbdkHome {
    if ($env:GBDK_HOME) { return $env:GBDK_HOME }
    $dir = Get-Item -LiteralPath $repoRoot
    while ($dir) {
        $candidate = Join-Path $dir.FullName 'work\tools\gbdk\gbdk'
        if ((Test-Path -LiteralPath (Join-Path $candidate 'bin\lcc.exe') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $candidate 'bin/lcc') -PathType Leaf)) { return $candidate }
        $candidate = Join-Path $dir.FullName 'gbdk'
        if ((Test-Path -LiteralPath (Join-Path $candidate 'bin\lcc.exe') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $candidate 'bin/lcc') -PathType Leaf)) { return $candidate }
        $dir = $dir.Parent
    }
    foreach ($candidate in @('C:\gbdk', 'C:\gbdk-2020', 'C:\tools\gbdk', '/Applications/GBDK', '/opt/homebrew/opt/gbdk', '/usr/local/opt/gbdk', '/opt/gbdk', '/usr/local/gbdk')) {
        if ((Test-Path -LiteralPath (Join-Path $candidate 'bin\lcc.exe') -PathType Leaf) -or (Test-Path -LiteralPath (Join-Path $candidate 'bin/lcc') -PathType Leaf)) { return $candidate }
    }
    return (Join-Path $repoRoot 'work\tools\gbdk\gbdk')
}
$gbdkHome = Find-GbdkHome
$lccExe = Join-Path $gbdkHome 'bin\lcc.exe'
$lccUnix = Join-Path $gbdkHome 'bin/lcc'
$lcc = if (Test-Path -LiteralPath $lccExe -PathType Leaf) { $lccExe } else { $lccUnix }

if (-not (Test-Path -LiteralPath $lcc -PathType Leaf)) {
    throw "Could not find GBDK lcc. Set GBDK_HOME to your GBDK-2020 folder. Tried: $lcc"
}

$outDir = Join-Path $repoRoot 'outputs'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$rom = Join-Path $outDir 'openai-flash-cart.gb'
$hugeInclude = Join-Path $repoRoot 'third_party/hUGEDriver/include'
$hugeLib = Join-Path $repoRoot 'third_party/hUGEDriver/gbdk/hUGEDriver.lib'
$sources = @(
    (Join-Path $projectRoot 'src\main.c'),
    (Join-Path $projectRoot 'src\uge_song.c')
)

& $lcc -Wm-yC -Wm-yn'OPENAIFLASH' "-I$hugeInclude" "-Wl-l$hugeLib" -o $rom $sources
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Built $rom"
