// Copyright 2023 Manna Harbour
// https://github.com/manna-harbour/miryoku

// This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

#pragma once

#define XXX KC_NO

// Undefine deprecated config option from miryoku userspace
#undef IGNORE_MOD_TAP_INTERRUPT

// Compatibility defines for old keycode names used in miryoku
#define KC_BTN1 MS_BTN1
#define KC_BTN2 MS_BTN2
#define KC_BTN3 MS_BTN3
#define KC_BTN4 MS_BTN4
#define KC_BTN5 MS_BTN5
#define KC_MS_U MS_UP
#define KC_MS_D MS_DOWN
#define KC_MS_L MS_LEFT
#define KC_MS_R MS_RGHT
#define KC_WH_U MS_WHLU
#define KC_WH_D MS_WHLD
#define KC_WH_L MS_WHLL
#define KC_WH_R MS_WHLR
#define KC_ACL0 MS_ACL0
#define KC_ACL1 MS_ACL1
#define KC_ACL2 MS_ACL2

// RGB keycodes - silakka54 doesn't have RGB, so disable these
#define RGB_TOG KC_NO
#define RGB_MOD KC_NO
#define RGB_HUI KC_NO
#define RGB_SAI KC_NO
#define RGB_VAI KC_NO
#define RGB_HUD KC_NO
#define RGB_SAD KC_NO
#define RGB_VAD KC_NO

// Custom symbol layer optimized for programming
// Brackets clustered together, common operators easily accessible
#define MIRYOKU_LAYER_SYM \
KC_PIPE,           KC_LT,             KC_GT,             KC_LBRC,           KC_RBRC,           U_NA,              TD(U_TD_U_BASE),   TD(U_TD_U_EXTRA),  TD(U_TD_U_TAP),    TD(U_TD_BOOT),     \
KC_PLUS,           KC_LPRN,           KC_RPRN,           KC_LCBR,           KC_RCBR,           U_NA,              KC_LSFT,           KC_LCTL,           KC_LALT,           KC_LGUI,           \
KC_EXLM,           KC_AT,             KC_HASH,           KC_DLR,            KC_PERC,           U_NA,              TD(U_TD_U_SYM),    TD(U_TD_U_MOUSE),  KC_ALGR,           U_NA,              \
U_NP,              U_NP,              KC_MINS,           KC_UNDS,           KC_EQL,            U_NA,              U_NA,              U_NA,              U_NP,              U_NP

// Custom Enthium alternative layout
// Layout from https://github.com/sunaku/enthium
// Left:                    Right:
// z y u o ;                q l d p x
// w c i e a ,              k h t n s f
// ' - = . /                j m g b v
//                          r
// Thumb keys: CAPS/MEDIA, BSPC/NAV, SPACE/MOUSE | ENTER/SYM, R/NUM, TAB/FUN
#define MIRYOKU_ALTERNATIVES_BASE_ENTHIUM \
KC_Z,              KC_Y,              KC_U,              KC_O,              KC_SCLN,           KC_Q,              KC_L,              KC_D,              KC_P,              KC_X,              \
KC_W,              LGUI_T(KC_C),      LALT_T(KC_I),      LCTL_T(KC_E),      LSFT_T(KC_A),      KC_K,              LSFT_T(KC_H),      LCTL_T(KC_T),      LALT_T(KC_N),      LGUI_T(KC_S),      \
KC_QUOT,           KC_MINS,           KC_EQL,            KC_DOT,            KC_SLSH,           KC_J,              KC_M,              KC_G,              KC_B,              KC_V,              \
U_NP,              U_NP,              KC_CAPS,           LT(U_NAV,KC_BSPC),LT(U_MOUSE,KC_SPC),LT(U_SYM,KC_ENT),  LT(U_NUM,KC_R),    LT(U_FUN,KC_TAB),  U_NP,              U_NP

#define MIRYOKU_LAYER_BASE MIRYOKU_ALTERNATIVES_BASE_ENTHIUM

// Custom MOUSE layer tweak for Silakka54:
// Bottom alpha row becomes: Shift | Play Vol- Vol+ Mute (empty) ...
#define MIRYOKU_LAYER_MOUSE \
TD(U_TD_BOOT),     TD(U_TD_U_TAP),    TD(U_TD_U_EXTRA),  TD(U_TD_U_BASE),   U_NA,              U_RDO,             U_PST,             U_CPY,             U_CUT,             U_UND,             \
KC_LGUI,           KC_LALT,           KC_LCTL,           KC_LSFT,           U_NA,              U_NU,              KC_MS_L,           KC_MS_D,           KC_MS_U,           KC_MS_R,           \
KC_MPLY,           KC_VOLD,           KC_VOLU,           KC_MUTE,           KC_NO,             U_NU,              KC_WH_L,           KC_WH_D,           KC_WH_U,           KC_WH_R,           \
U_NP,              U_NP,              U_NA,              U_NA,              U_NA,              KC_BTN2,           KC_BTN1,           KC_BTN3,           U_NP,              U_NP

// Custom NUM layer tweak for Silakka54:
// - Put `W` at the start of the "W-row" on NUM
// - Move `=` to the physical comma key on NUM (implemented in keymap.c)
#define MIRYOKU_LAYER_NUM \
KC_LBRC,           KC_7,              KC_8,              KC_9,              KC_RBRC,           U_NA,              TD(U_TD_U_BASE),   TD(U_TD_U_EXTRA),  TD(U_TD_U_TAP),    TD(U_TD_BOOT),     \
KC_W,              KC_SCLN,           KC_4,              KC_5,              KC_6,              U_NA,              KC_LSFT,           KC_LCTL,           KC_LALT,           KC_LGUI,           \
KC_GRV,            KC_1,              KC_2,              KC_3,              KC_BSLS,           U_NA,              TD(U_TD_U_NUM),    TD(U_TD_U_NAV),    KC_ALGR,           U_NA,              \
U_NP,              U_NP,              KC_DOT,            KC_0,              KC_MINS,           U_NA,              U_NA,              U_NA,              U_NP,              U_NP

// Miryoku layout wrapper for silakka54 - Enthium layout
// Uses all 5 rows of silakka54 (extra row compared to typical miryoku keyboards)
// Left:                          Right:
// `     1  2  3  4  5            6  7  8  9  0  DEL
// TAB   z  y  u  o  ;            q  l  d  p  x
// w     c  i  e  a  ,            k  h  t  n  s  f
// SHIFT '  -  =  .  /            j  m  g  b  v
//                                r
// Thumbs: CAPS, BSPC, SPACE      ENTER, R, TAB
#define LAYOUT_miryoku( \
     K00, K01, K02, K03, K04,                          K05, K06, K07, K08, K09, \
     K10, K11, K12, K13, K14,                          K15, K16, K17, K18, K19, \
     K20, K21, K22, K23, K24,                          K25, K26, K27, K28, K29, \
     N30, N31, K32, K33, K34,                          K35, K36, K37, N38, N39 \
) \
LAYOUT( \
  KC_GRV,  KC_1,    KC_2,  KC_3,  KC_4,  KC_5,           KC_6,  KC_7,  KC_8,    KC_9,   KC_0,    KC_DEL, \
  KC_TAB,  K00,     K01,   K02,   K03,   K04,            K05,   K06,   K07,     K08,    K09,     XXX, \
  K10,     K11,     K12,   K13,   K14,   KC_COMM,        K15,   K16,   K17,     K18,    K19,     KC_F,   \
  KC_LSFT, K20,     K21,   K22,   K23,   K24,            K25,   K26,   K27,     K28,    K29,     XXX, \
                                  K32,   K33,   K34,     K35,   K36,   K37 \
)

// Variant mapping:
// For some layers (NAV/MOUSE/MEDIA/FUN) we want the "W row" shifted one key to the right on the left half.
// Some layers have an unused key in that row (e.g. U_NA) and can keep the ',' key.
#define LAYOUT_miryoku_wrow_shift_right_keep_comma( \
     K00, K01, K02, K03, K04,                          K05, K06, K07, K08, K09, \
     K10, K11, K12, K13, K14,                          K15, K16, K17, K18, K19, \
     K20, K21, K22, K23, K24,                          K25, K26, K27, K28, K29, \
     N30, N31, K32, K33, K34,                          K35, K36, K37, N38, N39 \
) \
LAYOUT( \
  KC_GRV,  KC_1,    KC_2,  KC_3,  KC_4,  KC_5,           KC_6,  KC_7,  KC_8,    KC_9,   KC_0,    KC_DEL, \
  KC_TAB,  K00,     K01,   K02,   K03,   K04,            K05,   K06,   K07,     K08,    K09,     XXX, \
  K14,     K10,     K11,   K12,   K13,   KC_COMM,        K15,   K16,   K17,     K18,    K19,     KC_F,   \
  KC_LSFT, K20,     K21,   K22,   K23,   K24,            K25,   K26,   K27,     K28,    K29,     XXX, \
                                   K32,   K33,   K34,     K35,   K36,   K37 \
)

// For layers where that key isn't unused, shifting uses the comma position as the 6th slot and makes the far-left key no-op.
#define LAYOUT_miryoku_wrow_shift_right_drop_comma( \
     K00, K01, K02, K03, K04,                          K05, K06, K07, K08, K09, \
     K10, K11, K12, K13, K14,                          K15, K16, K17, K18, K19, \
     K20, K21, K22, K23, K24,                          K25, K26, K27, K28, K29, \
     N30, N31, K32, K33, K34,                          K35, K36, K37, N38, N39 \
) \
LAYOUT( \
  KC_GRV,  KC_1,    KC_2,  KC_3,  KC_4,  KC_5,           KC_6,  KC_7,  KC_8,    KC_9,   KC_0,    KC_DEL, \
  KC_TAB,  K00,     K01,   K02,   K03,   K04,            K05,   K06,   K07,     K08,    K09,     XXX, \
  KC_NO,   K10,     K11,   K12,   K13,   K14,            K15,   K16,   K17,     K18,    K19,     KC_F,   \
  KC_LSFT, K20,     K21,   K22,   K23,   K24,            K25,   K26,   K27,     K28,    K29,     XXX, \
                                   K32,   K33,   K34,     K35,   K36,   K37 \
)

// Override mapping for specific layers.
#define MIRYOKU_LAYERMAPPING_NAV   LAYOUT_miryoku_wrow_shift_right_keep_comma
#define MIRYOKU_LAYERMAPPING_MOUSE LAYOUT_miryoku_wrow_shift_right_keep_comma
#define MIRYOKU_LAYERMAPPING_MEDIA LAYOUT_miryoku_wrow_shift_right_keep_comma
#define MIRYOKU_LAYERMAPPING_FUN   LAYOUT_miryoku_wrow_shift_right_drop_comma
