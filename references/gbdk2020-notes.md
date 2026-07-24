# GBDK-2020 Notes

## Tool Discovery

Common GBDK locations on Windows:

- `$env:GBDK_HOME`
- `.\work\tools\gbdk\gbdk`
- `C:\gbdk`
- `C:\gbdk-2020`
- `C:\tools\gbdk`

Common mGBA locations:

- `$env:MGBA_EXE`
- `C:\Program Files\mGBA\mgba-sdl.exe`
- `C:\Program Files\mGBA\mGBA.exe`

Prefer project-local portable tools when a user wants a self-contained setup. Prefer installed tools when the user says they already have GBDK or mGBA.

## Console and Graphics Headers

Useful includes:

```c
#include <gb/gb.h>
#include <gb/cgb.h>
#include <gbdk/console.h>
#include <stdint.h>
#include <stdio.h>
```

`cls()` and `gotoxy()` are declared by `gbdk/console.h`.

## SRAM Pattern

Place variables in cart RAM from a separate C file:

```c
#include <gbdk/platform.h>
#include <stdint.h>

#pragma dataseg DATA_0

uint16_t save_magic;
uint8_t save_best_score;
```

In `main.c`:

```c
extern uint16_t save_magic;
extern uint8_t save_best_score;

ENABLE_RAM;
SWITCH_RAM(0);
save_magic = 0x4E42u;
```

Build with MBC + battery flags, for example:

```powershell
lcc -Wm-yC -Wl-yt0x1B -Wm-ya1 -o outputs\game.gb game\src\main.c game\src\save.c
```

## ROM Header Bytes

Useful offsets:

- `0x134..0x143`: title
- `0x143`: CGB flag
- `0x147`: cartridge type
- `0x148`: ROM size flag
- `0x149`: RAM size flag

Common values:

- `0x00`: ROM only
- `0x19`: MBC5
- `0x1A`: MBC5 + RAM
- `0x1B`: MBC5 + RAM + Battery
- `0x02` RAM size flag: 8 KiB external RAM
