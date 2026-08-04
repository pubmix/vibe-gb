$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $projectRoot
$outDir = Join-Path $repoRoot 'outputs'
$rom = Join-Path $outDir 'openai-flash-cart.gb'
$defaultMgbaSdl = 'C:\Program Files\mGBA\mgba-sdl.exe'
$defaultMgba = 'C:\Program Files\mGBA\mGBA.exe'
$defaultMgbaMac = '/Applications/mGBA.app/Contents/MacOS/mGBA'
$mgba = if ($env:MGBA_EXE) { $env:MGBA_EXE } elseif (Test-Path -LiteralPath $defaultMgbaSdl -PathType Leaf) { $defaultMgbaSdl } elseif (Test-Path -LiteralPath $defaultMgba -PathType Leaf) { $defaultMgba } else { $defaultMgbaMac }

if (-not (Test-Path -LiteralPath $rom -PathType Leaf)) {
    & (Join-Path $projectRoot 'build.ps1')
}

if (-not (Test-Path -LiteralPath $mgba -PathType Leaf)) {
    throw "Could not find mGBA. Set MGBA_EXE to your mGBA executable. Tried: $mgba"
}

Start-Process -FilePath $mgba -ArgumentList @($rom)
Write-Host "Launched $rom in mGBA"
