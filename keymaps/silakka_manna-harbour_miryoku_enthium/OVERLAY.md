## Silakka54 Layer Overlay (Raw HID)

This keymap sends layer state changes to the host over QMK Raw HID, so a host app can display an always-on-top overlay that updates instantly when you press/release momentary layers (e.g. hold `SYM`).

### Enablement

This keymap sets `RAW_ENABLE = yes` in `keyboards/silakka54/keymaps/manna-harbour_miryoku_enthium/rules.mk`.

### USB IDs / Raw HID interface

- USB VID/PID (from `keyboards/silakka54/keyboard.json`): `0xFEED` / `0x1212`
- Raw HID Usage Page / Usage ID (QMK defaults): `0xFF60` / `0x61`
- Report size: 32 bytes (`RAW_EPSIZE`)

### Report format (device → host)

All reports are 32 bytes.

- `byte[0]`: message type, `0x4C` (`'L'`) = layer update
- `byte[1]`: protocol version, currently `0x01`
- `byte[2]`: highest active layer (from `get_highest_layer(layer_state)`)
- `byte[3]`: highest default layer (from `get_highest_layer(default_layer_state)`)
- `byte[4..7]`: `layer_state` bitmask, little-endian `uint32`
- `byte[8..11]`: `default_layer_state` bitmask, little-endian `uint32`
- remaining bytes: `0x00`

### Layer numbers (Miryoku userspace)

This keymap uses the Miryoku userspace layer list (`users/manna-harbour_miryoku/miryoku_babel/miryoku_layer_list.h`):

```
0  BASE
1  EXTRA
2  TAP
3  BUTTON
4  NAV
5  MOUSE
6  MEDIA
7  NUM
8  SYM
9  FUN
```

The layers you called out are: `MEDIA=6`, `NAV=4`, `NUM=7`, `SYM=8`, `MOUSE=5`, `FUN=9`.
