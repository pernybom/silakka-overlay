# Silakka54 Screen Overlay (macOS)

Small always-on-top overlay that shows a Silakka54 key layout and updates instantly when your keyboard layer changes (Miryoku Enthium keymap).

## Prereqs

- Flash the firmware that includes Raw HID layer reporting:
  - Keymap: `keymaps/silakka_manna-harbour_miryoku_enthium`
- macOS 13+
- Xcode Command Line Tools (for Swift) or full Xcode.

## Build

```sh
swift build -c release
```

## Run

```sh
./.build/release/silakka54-overlay
```

- A small overlay appears (click-through by default).
- A menu bar item `Silakka54` lets you toggle click-through or quit.
- To move it: use the menu item `Toggle Click-Through` to disable click-through, then drag the overlay window.
- The overlay listens to the QMK Raw HID interface on:
  - VID/PID: `0xFEED` / `0x1212`
  - Usage Page/ID: `0xFF60` / `0x61`

## Debug (no UI)

Prints current layer changes to stderr:

```sh
./.build/release/silakka54-overlay --no-ui
```

## Notes

- Layer indices follow Miryoku userspace (`BASE=0`, `NAV=4`, `MOUSE=5`, `MEDIA=6`, `NUM=7`, `SYM=8`, `FUN=9`).
- This app renders tap legends only (e.g. `LT(U_SYM,KC_ENT)` shows `Enter`).
- The Silakka54 key positions are loaded from `keyboards/silakka54/keyboard.json` by searching upward from the current working directory; run it from inside the `qmk_firmware` tree.
