param(
    [string]$Name = "gb-game",
    [string]$ProjectDir = ".\game",
    [string]$OutputDir = ".\outputs"
)

$ErrorActionPreference = "Stop"

function Convert-ToRomName([string]$value) {
    $name = $value.ToLowerInvariant() -replace '[^a-z0-9]+', '-'
    $name = $name.Trim('-')
    if (-not $name) { $name = "gb-game" }
    return $name
}

$romName = Convert-ToRomName $Name
$title = (($romName -replace '-', '').ToUpperInvariant())
if ($title.Length -gt 11) { $title = $title.Substring(0, 11) }

$projectRoot = Resolve-Path -LiteralPath "."
$gameDir = Join-Path $projectRoot $ProjectDir
$srcDir = Join-Path $gameDir "src"
$outDir = Join-Path $projectRoot $OutputDir

New-Item -ItemType Directory -Force -Path $srcDir, $outDir | Out-Null

$main = @"
#include <gb/gb.h>
#include <gb/cgb.h>
#include <gbdk/console.h>
#include <stdint.h>
#include <stdio.h>

static const palette_color_t palettes[] = {
    RGB8(255, 255, 255), RGB8(178, 214, 122), RGB8(64, 92, 74), RGB8(12, 18, 22)
};

void main(void) {
    DISPLAY_ON;
    set_bkg_palette(0, 1, palettes);
    cls();
    gotoxy(6, 6); printf("Vibe GB");
    gotoxy(5, 8); printf("by ModRetro");

    while (1) {
        wait_vbl_done();
    }
}
"@

$build = @"
`$ErrorActionPreference = 'Stop'

`$projectRoot = Split-Path -Parent `$MyInvocation.MyCommand.Path
`$repoRoot = Split-Path -Parent `$projectRoot
function Find-GbdkHome {
    if (`$env:GBDK_HOME) { return `$env:GBDK_HOME }
    `$dir = Get-Item -LiteralPath `$repoRoot
    while (`$dir) {
        `$candidate = Join-Path `$dir.FullName 'work\tools\gbdk\gbdk'
        if (Test-Path -LiteralPath (Join-Path `$candidate 'bin\lcc.exe') -PathType Leaf) { return `$candidate }
        `$candidate = Join-Path `$dir.FullName 'gbdk'
        if (Test-Path -LiteralPath (Join-Path `$candidate 'bin\lcc.exe') -PathType Leaf) { return `$candidate }
        `$dir = `$dir.Parent
    }
    foreach (`$candidate in @('C:\gbdk', 'C:\gbdk-2020', 'C:\tools\gbdk')) {
        if (Test-Path -LiteralPath (Join-Path `$candidate 'bin\lcc.exe') -PathType Leaf) { return `$candidate }
    }
    return (Join-Path `$repoRoot 'work\tools\gbdk\gbdk')
}
`$gbdkHome = Find-GbdkHome
`$lcc = Join-Path `$gbdkHome 'bin\lcc.exe'

if (-not (Test-Path -LiteralPath `$lcc -PathType Leaf)) {
    throw "Could not find GBDK lcc.exe. Set GBDK_HOME to your GBDK-2020 folder. Tried: `$lcc"
}

`$outDir = Join-Path `$repoRoot '$($OutputDir.TrimStart('.\'))'
New-Item -ItemType Directory -Force -Path `$outDir | Out-Null

`$rom = Join-Path `$outDir '$romName.gb'
`$source = Join-Path `$projectRoot 'src\main.c'

& `$lcc -Wm-yC -Wm-yn'$title' -o `$rom `$source
if (`$LASTEXITCODE -ne 0) { exit `$LASTEXITCODE }
Write-Host "Built `$rom"
"@

$run = @"
`$ErrorActionPreference = 'Stop'

`$projectRoot = Split-Path -Parent `$MyInvocation.MyCommand.Path
`$repoRoot = Split-Path -Parent `$projectRoot
`$rom = Join-Path `$repoRoot '$($OutputDir.TrimStart('.\'))\$romName.gb'
`$defaultMgbaSdl = 'C:\Program Files\mGBA\mgba-sdl.exe'
`$defaultMgba = 'C:\Program Files\mGBA\mGBA.exe'
`$mgba = if (`$env:MGBA_EXE) { `$env:MGBA_EXE } elseif (Test-Path -LiteralPath `$defaultMgbaSdl -PathType Leaf) { `$defaultMgbaSdl } else { `$defaultMgba }

if (-not (Test-Path -LiteralPath `$rom -PathType Leaf)) {
    & (Join-Path `$projectRoot 'build.ps1')
}

if (-not (Test-Path -LiteralPath `$mgba -PathType Leaf)) {
    throw "Could not find mGBA. Set MGBA_EXE to your mGBA executable. Tried: `$mgba"
}

Start-Process -FilePath `$mgba -ArgumentList @(`$rom)
Write-Host "Launched `$rom in mGBA"
"@

$readme = @"
# $Name

GBDK-2020 Game Boy project.

The starter ROM displays:

```text
Vibe GB
by ModRetro
```

Use this as a clean prompt-ready cartridge screen, then replace `src\main.c` as the game takes shape.

Build:

````powershell
.\$($ProjectDir.TrimStart('.\'))\build.ps1
````

Run:

````powershell
.\$($ProjectDir.TrimStart('.\'))\run.ps1
````

Output:

````text
$($OutputDir.TrimStart('.\'))\$romName.gb
````
"@

Set-Content -LiteralPath (Join-Path $srcDir "main.c") -Value $main -Encoding ASCII
Set-Content -LiteralPath (Join-Path $gameDir "build.ps1") -Value $build -Encoding ASCII
Set-Content -LiteralPath (Join-Path $gameDir "run.ps1") -Value $run -Encoding ASCII
Set-Content -LiteralPath (Join-Path $gameDir "README.md") -Value $readme -Encoding ASCII

Write-Host "Created GBDK-2020 .gb project:"
Write-Host "  Project: $gameDir"
Write-Host "  ROM:     $(Join-Path $outDir "$romName.gb")"
