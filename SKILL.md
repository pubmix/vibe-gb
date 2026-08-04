---
name: vibe-gb
description: Create, build, iterate, and test Game Boy .gb games with GBDK-2020 and mGBA. Use when the user asks to make a .gb/.gbc-style Game Boy ROM, set up a GBDK-2020 build chain, scaffold a new GB game project, convert a game idea into GBDK C code, build with lcc, inspect ROM headers, or launch/test the ROM in mGBA.
---

# GBDK-2020 GB Game

Use this skill to produce a real Game Boy `.gb` ROM, not just a mockup. Prefer a runnable, buildable project with `src/main.c`, `build.ps1`, `run.ps1`, and an `outputs/*.gb` ROM.

## Workflow

1. Inspect the workspace before editing.
2. Locate tools:
   - Prefer `GBDK_HOME` when set.
   - Otherwise look for `gbdk\bin\lcc.exe`, `gbdk-2020\bin\lcc.exe`, `gbdk/bin/lcc`, or a workspace copy under `work/tools/gbdk/gbdk`.
   - On macOS, also check common install paths such as `/Applications/GBDK`, `/opt/homebrew/opt/gbdk`, `/usr/local/opt/gbdk`, and `/opt/gbdk`.
   - Prefer `MGBA_EXE` when set.
   - Otherwise look for `C:\Program Files\mGBA\mgba-sdl.exe`, then `C:\Program Files\mGBA\mGBA.exe`.
   - On macOS, also look for `/Applications/mGBA.app/Contents/MacOS/mGBA`.
3. If no project exists, run `scripts/new_gbdk_project.ps1` to scaffold one.
4. Implement the game in GBDK C. Keep the first ROM small and reliable, then iterate.
5. Build with `game/build.ps1`.
6. Inspect the ROM with `scripts/inspect_rom.ps1`.
7. Launch with `game/run.ps1`; GUI launch may require escalation.
8. If the ROM is locked by mGBA, stop only the mGBA process or ask the user to close it, then rebuild.

## Project Scaffold

Run from the target workspace:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <skill>/scripts/new_gbdk_project.ps1 -Name my-game
```

The script creates:

- `game/src/main.c`
- `game/build.ps1`
- `game/run.ps1`
- `game/README.md`
- `outputs/`

It emits `outputs/<name>.gb` by default.

The default starter ROM is a prompt-ready splash screen:

```text
Vibe GB
Ready
```

Use that as the first running cartridge, then replace or expand `game/src/main.c` with the user's requested game.

## Build Flags

Use these defaults for a normal `.gb` ROM that is Game Boy Color aware:

```powershell
lcc -Wm-yC -Wm-yn'TITLE' -o outputs\game.gb game\src\main.c
```

Use these flags when battery-backed saves are needed:

```powershell
lcc -Wm-yC -Wl-yt0x1B -Wm-ya1 -Wm-yn'TITLE' -o outputs\game.gb game\src\main.c game\src\save.c
```

Notes:

- `-Wm-yC` marks the ROM as CGB-aware while keeping `.gb`.
- `-Wl-yt0x1B` sets MBC5 + RAM + Battery.
- `-Wm-ya1` requests one external RAM bank.
- Keep ROM title short; the Game Boy header is limited.

## GBDK C Rules

- Include console helpers with `#include <gbdk/console.h>`.
- Include platform APIs with `#include <gb/gb.h>` and `#include <gb/cgb.h>`.
- Use `wait_vbl_done()` in game loops.
- Use `joypad()`, `waitpadup()`, and explicit debouncing for menus.
- Use `set_bkg_data`, `set_bkg_tile_xy`, `set_sprite_data`, `set_sprite_tile`, and `move_sprite` for graphics.
- Hide unused sprites by moving them to `(0, 0)`.
- Keep the first pass compact; a 32 KiB ROM is acceptable.

For SRAM examples and header notes, read `references/gbdk2020-notes.md`.

## Validation

Always verify:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File game\build.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File <skill>\scripts\inspect_rom.ps1 -Rom outputs\my-game.gb
```

Expected for a CGB-aware `.gb`:

- Extension: `.gb`
- CGB flag: `0x80` or `0xC0`
- Nonzero byte size, usually `32768` or larger

Expected for save-enabled carts:

- Cart type: `0x1B`
- RAM flag: nonzero
- mGBA creates/updates a `.sav` next to the ROM.

When launching mGBA:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File game\run.ps1
```

Use escalation for GUI launch if required by the environment.
