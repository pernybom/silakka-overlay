# Copyright 2023 Manna Harbour
# https://github.com/manna-harbour/miryoku

USER_NAME := manna-harbour_miryoku

MOUSEKEY_ENABLE = yes
EXTRAKEY_ENABLE = yes
AUTO_SHIFT_ENABLE = yes
TAP_DANCE_ENABLE = yes
CAPS_WORD_ENABLE = yes
KEY_OVERRIDE_ENABLE = yes
RAW_ENABLE = yes

INTROSPECTION_KEYMAP_C = users/manna-harbour_miryoku/manna-harbour_miryoku.c

include users/manna-harbour_miryoku/custom_rules.mk
include users/manna-harbour_miryoku/post_rules.mk
