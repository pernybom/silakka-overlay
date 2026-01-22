// Copyright 2023 Manna Harbour
// https://github.com/manna-harbour/miryoku

// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

#include QMK_KEYBOARD_H
#include "manna-harbour_miryoku.h"

#ifdef RAW_ENABLE
#    include "raw_hid.h"
#    include "usb_descriptor.h"
#    include <string.h>

enum {
    SILAKKA54_OVERLAY_MSG_LAYER = 0x4C, // 'L'
};

static void silakka54_overlay_send_layer_state(layer_state_t layer, layer_state_t default_layer) {
    uint8_t report[RAW_EPSIZE];
    memset(report, 0, sizeof(report));

    report[0] = SILAKKA54_OVERLAY_MSG_LAYER;
    report[1] = 0x01; // protocol version
    report[2] = (uint8_t)get_highest_layer(layer);
    report[3] = (uint8_t)get_highest_layer(default_layer);

    const uint32_t layer_u32         = (uint32_t)layer;
    const uint32_t default_layer_u32 = (uint32_t)default_layer;

    report[4]  = (uint8_t)(layer_u32 >> 0);
    report[5]  = (uint8_t)(layer_u32 >> 8);
    report[6]  = (uint8_t)(layer_u32 >> 16);
    report[7]  = (uint8_t)(layer_u32 >> 24);
    report[8]  = (uint8_t)(default_layer_u32 >> 0);
    report[9]  = (uint8_t)(default_layer_u32 >> 8);
    report[10] = (uint8_t)(default_layer_u32 >> 16);
    report[11] = (uint8_t)(default_layer_u32 >> 24);

    raw_hid_send(report, RAW_EPSIZE);
}
#endif

void keyboard_post_init_user(void) {
#ifdef RAW_ENABLE
    silakka54_overlay_send_layer_state(layer_state, default_layer_state);
#endif
}

layer_state_t layer_state_set_user(layer_state_t state) {
#ifdef RAW_ENABLE
    static layer_state_t last_layer_state = 0;
    if (state != last_layer_state) {
        last_layer_state = state;
        silakka54_overlay_send_layer_state(state, default_layer_state);
    }
#endif
    return state;
}

layer_state_t default_layer_state_set_user(layer_state_t state) {
#ifdef RAW_ENABLE
    static layer_state_t last_default_layer_state = 0;
    if (state != last_default_layer_state) {
        last_default_layer_state = state;
        silakka54_overlay_send_layer_state(layer_state, state);
    }
#endif
    return state;
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    // Custom NUM layer tweak: make the physical comma key behave as '=' when NUM is the highest layer.
    if (keycode == KC_COMM && get_highest_layer(layer_state) == U_NUM) {
        if (record->event.pressed) {
            register_code16(KC_EQL);
        } else {
            unregister_code16(KC_EQL);
        }
        return false;
    }

    return true;
}
