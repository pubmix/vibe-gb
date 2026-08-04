# Vibe GB by ModRetro

This repository contains a Codex skill for creating, building, iterating, and testing real Game Boy `.gb` ROMs with [GBDK-2020](https://github.com/gbdk-2020/gbdk-2020) and [mGBA](https://mgba.io/).

The skill helps Codex scaffold a small GBDK project, compile it with `lcc`, inspect the generated ROM header, and launch the ROM in mGBA. The starter ROM is intentionally simple: it boots to a clean `Vibe GB` / `Ready` screen so the project is ready for the next prompt-driven iteration.

## What This Skill Does

- Creates a buildable Game Boy project with `game/src/main.c`
- Starts from a splash screen that says `Vibe GB` and `Ready`
- Generates `game/build.ps1` and `game/run.ps1`
- Builds a real `.gb` ROM, usually into `outputs/<name>.gb`
- Uses GBDK-2020 `lcc`
- Uses mGBA or `mgba-sdl.exe` for testing
- Supports Game Boy Color-aware `.gb` builds
- Documents save-RAM / battery-backed cartridge settings
- Includes a ROM header inspection script

## Included Demo ROM

This repo includes the current OpenAI flash-cart ROM at:

```text
outputs/openai-flash-cart.gb
```

You can run it directly in mGBA, or put it on a compatible flash cart.

## Required Software

### Codex

You need Codex with local skill support. Install this folder into your Codex skills directory:

```text
~/.codex/skills/vibe-gb
```

On Windows:

```text
C:\Users\<you>\.codex\skills\vibe-gb
```

### GBDK-2020

Install or unpack GBDK-2020 so `lcc.exe` on Windows or `lcc` on macOS is available.

The skill looks for GBDK in this order:

1. `GBDK_HOME` environment variable
2. `work\tools\gbdk\gbdk` inside the workspace or a parent folder
3. `gbdk` inside the workspace or a parent folder
4. Windows defaults: `C:\gbdk`, `C:\gbdk-2020`, `C:\tools\gbdk`
5. macOS defaults: `/Applications/GBDK`, `/opt/homebrew/opt/gbdk`, `/usr/local/opt/gbdk`, `/opt/gbdk`, `/usr/local/gbdk`

If GBDK is somewhere else, set:

```powershell
$env:GBDK_HOME = "C:\path\to\gbdk"
```

On macOS with `pwsh`:

```powershell
$env:GBDK_HOME = "/path/to/gbdk"
```

### mGBA

Install mGBA for emulator testing.

The skill looks for mGBA in this order:

1. `MGBA_EXE` environment variable
2. `C:\Program Files\mGBA\mgba-sdl.exe`
3. `C:\Program Files\mGBA\mGBA.exe`
4. `/Applications/mGBA.app/Contents/MacOS/mGBA`

If mGBA is somewhere else, set:

```powershell
$env:MGBA_EXE = "C:\path\to\mGBA.exe"
```

On macOS with `pwsh`:

```powershell
$env:MGBA_EXE = "/Applications/mGBA.app/Contents/MacOS/mGBA"
```

### PowerShell

The included helper scripts are PowerShell scripts. Use Windows PowerShell or PowerShell 7+ (`pwsh`) on Windows/macOS. The `.ps1` extension means "PowerShell script", not PlayStation 1.

## How To Use

After installing the skill, start a Codex task and ask:

```text
Use $vibe-gb to create a new Game Boy .gb project and run it in mGBA.
```

Or:

```text
Use $vibe-gb to build a complete .gb game from this idea: ...
```

## Manual Script Usage

You can also run the bundled scripts directly.

### Create a New Project

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\new_gbdk_project.ps1 -Name my-game
```

This creates:

```text
game\src\main.c
game\build.ps1
game\run.ps1
game\README.md
outputs\my-game.gb
```

The generated `main.c` boots to:

```text
Vibe GB
Ready
```

### Build

```powershell
.\game\build.ps1
```

### Run In mGBA

```powershell
.\game\run.ps1
```

### Inspect ROM Header

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\inspect_rom.ps1 -Rom .\outputs\my-game.gb
```

Example output:

```text
Title       : SMOKETEST
CgbFlag     : 0xC0
CartType    : 0x00
RomSizeFlag : 0x00
RamSizeFlag : 0x00
Bytes       : 32768
```

## Cartridge Notes

For a normal CGB-aware `.gb`:

```powershell
lcc -Wm-yC -Wm-yn'TITLE' -o outputs\game.gb game\src\main.c
```

For a save-enabled `.gb`:

```powershell
lcc -Wm-yC -Wl-yt0x1B -Wm-ya1 -Wm-yn'TITLE' -o outputs\game.gb game\src\main.c game\src\save.c
```

Important flags:

- `-Wm-yC`: mark the ROM as Game Boy Color-aware while keeping `.gb`
- `-Wl-yt0x1B`: MBC5 + RAM + Battery
- `-Wm-ya1`: one external RAM bank
- `-Wm-yn'TITLE'`: cartridge title

## Repository Contents

```text
SKILL.md
agents\openai.yaml
references\gbdk2020-notes.md
scripts\new_gbdk_project.ps1
scripts\inspect_rom.ps1
outputs\openai-flash-cart.gb
```

## License

Dual-licensed under either MIT or Apache-2.0, at your option. See `LICENSE-MIT` and `LICENSE-APACHE`.
