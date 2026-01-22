import Foundation

final class Silakka54MiryokuEnthiumKeymap {
    // Miryoku userspace layer order:
    // 0 BASE, 1 EXTRA, 2 TAP, 3 BUTTON, 4 NAV, 5 MOUSE, 6 MEDIA, 7 NUM, 8 SYM, 9 FUN
    private let layerNames: [Int: String] = [
        0: "BASE",
        1: "EXTRA",
        2: "TAP",
        3: "BUTTON",
        4: "NAV",
        5: "MOUSE",
        6: "MEDIA",
        7: "NUM",
        8: "SYM",
        9: "FUN",
    ]

    private let layer40: [Int: [String]] = [
        0: Silakka54MiryokuEnthiumKeymap.baseLayer40,
        4: Silakka54MiryokuEnthiumKeymap.navLayer40,
        5: Silakka54MiryokuEnthiumKeymap.mouseLayer40,
        6: Silakka54MiryokuEnthiumKeymap.mediaLayer40,
        7: Silakka54MiryokuEnthiumKeymap.numLayer40,
        8: Silakka54MiryokuEnthiumKeymap.symLayer40,
        9: Silakka54MiryokuEnthiumKeymap.funLayer40,
    ]

    func layerName(for layerIndex: Int) -> String {
        layerNames[layerIndex] ?? "L\(layerIndex)"
    }

    func labelsForLayerIndex(_ layerIndex: Int) -> [String] {
        let fallback = layer40[0] ?? Array(repeating: "KC_NO", count: 40)
        let src = layer40[layerIndex] ?? fallback
        var expanded = expand40To54(src, layerIndex: layerIndex)
        return expanded.map { KeyLegend.tapLegend(for: $0) }
    }

    private func expand40To54(_ src: [String], layerIndex: Int) -> [String] {
        guard src.count == 40 else { return Array(repeating: "", count: 54) }

        var out = Array(repeating: "", count: 54)

        // Row 0 (fixed)
        out[0] = "KC_GRV"
        out[1] = "KC_1"
        out[2] = "KC_2"
        out[3] = "KC_3"
        out[4] = "KC_4"
        out[5] = "KC_5"
        out[6] = "KC_6"
        out[7] = "KC_7"
        out[8] = "KC_8"
        out[9] = "KC_9"
        out[10] = "KC_0"
        out[11] = "KC_DEL"

        // Row 1
        out[12] = "KC_TAB"
        for i in 0..<10 { out[13 + i] = src[i] } // K00..K09
        out[23] = "KC_NO" // XXX

        // Row 2
        switch wRowShiftMode(layerIndex) {
        case .none:
            for i in 0..<5 { out[24 + i] = src[10 + i] } // K10..K14
            out[29] = (layerIndex == 7) ? "KC_EQL" : "KC_COMM"
        case .keepComma:
            // Matches `LAYOUT_miryoku_wrow_shift_right_keep_comma`:
            // K14, K10, K11, K12, K13, KC_COMM,  K15..K19, KC_F
            out[24] = src[14] // K14
            for i in 0..<4 { out[25 + i] = src[10 + i] } // K10..K13
            out[29] = "KC_COMM"
        case .dropComma:
            // Matches `LAYOUT_miryoku_wrow_shift_right_drop_comma`:
            // KC_NO, K10, K11, K12, K13, K14,  K15..K19, KC_F
            out[24] = "KC_NO"
            for i in 0..<5 { out[25 + i] = src[10 + i] } // K10..K14
        }
        for i in 0..<5 { out[30 + i] = src[15 + i] } // K15..K19
        out[35] = "KC_F"

        // Row 3
        out[36] = "KC_LSFT"
        for i in 0..<10 { out[37 + i] = src[20 + i] } // K20..K29
        out[47] = "KC_NO" // XXX

        // Row 4 (thumbs)
        for i in 0..<6 { out[48 + i] = src[32 + i] } // K32..K37

        return out
    }

    private enum WRowShiftMode {
        case none
        case keepComma
        case dropComma
    }

    private func wRowShiftMode(_ layerIndex: Int) -> WRowShiftMode {
        // NAV, MOUSE, MEDIA: keep comma slot; FUN: drop it.
        if layerIndex == 4 || layerIndex == 5 || layerIndex == 6 { return .keepComma }
        if layerIndex == 9 { return .dropComma }
        return .none
    }
}

enum KeyLegend {
    static func tapLegend(for token: String) -> String {
        let t = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return "" }

        // Not present / not used / disabled.
        if t == "KC_NO" || t == "XXX" || t == "U_NA" || t == "U_NP" || t == "U_NU" { return "" }
        if t.hasPrefix("RGB_") { return "" }

        if let inner = extractLastArg(call: "LT", from: t) { return tapLegend(for: inner) }

        if let inner = extractSingleArgFromSuffixT(from: t) { return tapLegend(for: inner) }

        if let inner = extractSingleArg(call: "TD", from: t) {
            return tapDanceLegend(inner)
        }

        if t == "KC_LGUI" { return "Cmd" }
        if t == "KC_LALT" { return "Opt" }
        if t == "KC_LCTL" { return "Ctrl" }
        if t == "KC_LSFT" { return "Shift" }
        if t == "KC_ALGR" { return "AltGr" }
        if t == "CW_TOGG" { return "CapsWord" }

        if t == "U_UND" { return "Undo" }
        if t == "U_RDO" { return "Redo" }
        if t == "U_CUT" { return "Cut" }
        if t == "U_CPY" { return "Copy" }
        if t == "U_PST" { return "Paste" }

        if t == "KC_MS_U" { return "MS↑" }
        if t == "KC_MS_D" { return "MS↓" }
        if t == "KC_MS_L" { return "MS←" }
        if t == "KC_MS_R" { return "MS→" }
        if t == "KC_WH_U" { return "WH↑" }
        if t == "KC_WH_D" { return "WH↓" }
        if t == "KC_WH_L" { return "WH←" }
        if t == "KC_WH_R" { return "WH→" }
        if t == "KC_BTN1" { return "Btn1" }
        if t == "KC_BTN2" { return "Btn2" }
        if t == "KC_BTN3" { return "Btn3" }

        if t == "KC_MPLY" { return "Play" }
        if t == "KC_MSTP" { return "Stop" }
        if t == "KC_MUTE" { return "Mute" }
        if t == "KC_MPRV" { return "Prev" }
        if t == "KC_MNXT" { return "Next" }
        if t == "KC_VOLU" { return "Vol+" }
        if t == "KC_VOLD" { return "Vol-" }
        if t == "OU_AUTO" { return "Auto" }

        if t == "KC_ESC" { return "Esc" }
        if t == "KC_TAB" { return "Tab" }
        if t == "KC_ENT" { return "Enter" }
        if t == "KC_BSPC" { return "Bksp" }
        if t == "KC_DEL" { return "Del" }
        if t == "KC_SPC" { return "Space" }

        if t == "KC_LEFT" { return "←" }
        if t == "KC_RGHT" { return "→" }
        if t == "KC_UP" { return "↑" }
        if t == "KC_DOWN" { return "↓" }
        if t == "KC_HOME" { return "Home" }
        if t == "KC_END" { return "End" }
        if t == "KC_PGUP" { return "PgUp" }
        if t == "KC_PGDN" { return "PgDn" }
        if t == "KC_INS" { return "Ins" }

        if let letter = stripPrefix("KC_", from: t), letter.count == 1, letter.first?.isLetter == true {
            return letter.uppercased()
        }
        if t == "KC_1" { return "1" }
        if t == "KC_2" { return "2" }
        if t == "KC_3" { return "3" }
        if t == "KC_4" { return "4" }
        if t == "KC_5" { return "5" }
        if t == "KC_6" { return "6" }
        if t == "KC_7" { return "7" }
        if t == "KC_8" { return "8" }
        if t == "KC_9" { return "9" }
        if t == "KC_0" { return "0" }

        if t == "KC_GRV" { return "`" }
        if t == "KC_TILD" { return "~" }
        if t == "KC_EXLM" { return "!" }
        if t == "KC_AT" { return "@" }
        if t == "KC_HASH" { return "#" }
        if t == "KC_DLR" { return "$" }
        if t == "KC_PERC" { return "%" }
        if t == "KC_CIRC" { return "^" }
        if t == "KC_AMPR" { return "&" }
        if t == "KC_ASTR" { return "*" }
        if t == "KC_MINS" { return "-" }
        if t == "KC_UNDS" { return "_" }
        if t == "KC_EQL" { return "=" }
        if t == "KC_PLUS" { return "+" }
        if t == "KC_LBRC" { return "[" }
        if t == "KC_RBRC" { return "]" }
        if t == "KC_LCBR" { return "{" }
        if t == "KC_RCBR" { return "}" }
        if t == "KC_BSLS" { return "\\" }
        if t == "KC_PIPE" { return "|" }
        if t == "KC_SCLN" { return ";" }
        if t == "KC_COLN" { return ":" }
        if t == "KC_QUOT" { return "'" }
        if t == "KC_DQUO" { return "\"" }
        if t == "KC_COMM" { return "," }
        if t == "KC_DOT" { return "." }
        if t == "KC_SLSH" { return "/" }
        if t == "KC_LPRN" { return "(" }
        if t == "KC_RPRN" { return ")" }
        if t == "KC_LT" { return "<" }
        if t == "KC_GT" { return ">" }

        if t == "KC_PSCR" { return "PrtSc" }
        if t == "KC_SCRL" { return "ScrLk" }
        if t == "KC_PAUS" { return "Pause" }
        if t == "KC_APP" { return "App" }

        if let f = stripPrefix("KC_F", from: t), let n = Int(f), (1...24).contains(n) {
            return "F\(n)"
        }

        return t
    }

    private static func stripPrefix(_ prefix: String, from s: String) -> String? {
        guard s.hasPrefix(prefix) else { return nil }
        return String(s.dropFirst(prefix.count))
    }

    private static func extractSingleArg(call: String, from s: String) -> String? {
        let prefix = "\(call)("
        guard s.hasPrefix(prefix), s.hasSuffix(")") else { return nil }
        let inner = String(s.dropFirst(prefix.count).dropLast())
        return inner.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func extractLastArg(call: String, from s: String) -> String? {
        let prefix = "\(call)("
        guard s.hasPrefix(prefix), s.hasSuffix(")") else { return nil }
        let inner = String(s.dropFirst(prefix.count).dropLast())
        let parts = inner.split(separator: ",", maxSplits: 10, omittingEmptySubsequences: true)
        guard let last = parts.last else { return nil }
        return last.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func extractSingleArgFromSuffixT(from s: String) -> String? {
        // Matches patterns like LGUI_T(KC_A), LSFT_T(KC_A), LCTL_T(KC_A), etc.
        guard let open = s.firstIndex(of: "("), s.hasSuffix(")"), s.contains("_T(") else { return nil }
        let inner = String(s[s.index(after: open)..<s.index(before: s.endIndex)])
        return inner.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func tapDanceLegend(_ inner: String) -> String {
        switch inner {
        case "U_TD_BOOT": return "Boot"
        case "U_TD_U_BASE": return "Base"
        case "U_TD_U_EXTRA": return "Extra"
        case "U_TD_U_TAP": return "Tap"
        case "U_TD_U_BUTTON": return "Btn"
        case "U_TD_U_NAV": return "Nav"
        case "U_TD_U_MOUSE": return "Mouse"
        case "U_TD_U_MEDIA": return "Media"
        case "U_TD_U_NUM": return "Num"
        case "U_TD_U_SYM": return "Sym"
        case "U_TD_U_FUN": return "Fun"
        default: return "TD"
        }
    }
}

extension Silakka54MiryokuEnthiumKeymap {
    // Derived from `keyboards/silakka54/keymaps/manna-harbour_miryoku_enthium/config.h`
    static let baseLayer40: [String] = [
        "KC_Z", "KC_Y", "KC_U", "KC_O", "KC_SCLN", "KC_Q", "KC_L", "KC_D", "KC_P", "KC_X",
        "KC_W", "LGUI_T(KC_C)", "LALT_T(KC_I)", "LCTL_T(KC_E)", "LSFT_T(KC_A)", "KC_K", "LSFT_T(KC_H)", "LCTL_T(KC_T)", "LALT_T(KC_N)", "LGUI_T(KC_S)",
        "KC_QUOT", "KC_MINS", "KC_EQL", "KC_DOT", "KC_SLSH", "KC_J", "KC_M", "KC_G", "KC_B", "KC_V",
        "U_NP", "U_NP", "KC_CAPS", "LT(U_NAV,KC_BSPC)", "LT(U_MOUSE,KC_SPC)", "LT(U_SYM,KC_ENT)", "LT(U_NUM,KC_R)", "LT(U_FUN,KC_TAB)", "U_NP", "U_NP",
    ]

    // Derived from `keyboards/silakka54/keymaps/manna-harbour_miryoku_enthium/config.h` (custom SYM)
    static let symLayer40: [String] = [
        "KC_PIPE", "KC_LT", "KC_GT", "KC_LBRC", "KC_RBRC", "U_NA", "TD(U_TD_U_BASE)", "TD(U_TD_U_EXTRA)", "TD(U_TD_U_TAP)", "TD(U_TD_BOOT)",
        "KC_PLUS", "KC_LPRN", "KC_RPRN", "KC_LCBR", "KC_RCBR", "U_NA", "KC_LSFT", "KC_LCTL", "KC_LALT", "KC_LGUI",
        "KC_EXLM", "KC_AT", "KC_HASH", "KC_DLR", "KC_PERC", "U_NA", "TD(U_TD_U_SYM)", "TD(U_TD_U_MOUSE)", "KC_ALGR", "U_NA",
        "U_NP", "U_NP", "KC_MINS", "KC_UNDS", "KC_EQL", "U_NA", "U_NA", "U_NA", "U_NP", "U_NP",
    ]

    // Derived from `users/manna-harbour_miryoku/miryoku_babel/miryoku_layer_alternatives.h` (MIRYOKU_ALTERNATIVES_NAV)
    static let navLayer40: [String] = [
        "TD(U_TD_BOOT)", "TD(U_TD_U_TAP)", "TD(U_TD_U_EXTRA)", "TD(U_TD_U_BASE)", "U_NA", "U_RDO", "U_PST", "U_CPY", "U_CUT", "U_UND",
        "KC_LGUI", "KC_LALT", "KC_LCTL", "KC_LSFT", "U_NA", "CW_TOGG", "KC_LEFT", "KC_DOWN", "KC_UP", "KC_RGHT",
        "U_NA", "KC_ALGR", "TD(U_TD_U_NUM)", "TD(U_TD_U_NAV)", "U_NA", "KC_INS", "KC_HOME", "KC_PGDN", "KC_PGUP", "KC_END",
        "U_NP", "U_NP", "U_NA", "U_NA", "U_NA", "KC_ENT", "KC_BSPC", "KC_DEL", "U_NP", "U_NP",
    ]

    // Derived from `keyboards/silakka54/keymaps/manna-harbour_miryoku_enthium/config.h` (custom MIRYOKU_LAYER_MOUSE)
    static let mouseLayer40: [String] = [
        "TD(U_TD_BOOT)", "TD(U_TD_U_TAP)", "TD(U_TD_U_EXTRA)", "TD(U_TD_U_BASE)", "U_NA", "U_RDO", "U_PST", "U_CPY", "U_CUT", "U_UND",
        "KC_LGUI", "KC_LALT", "KC_LCTL", "KC_LSFT", "U_NA", "U_NU", "KC_MS_L", "KC_MS_D", "KC_MS_U", "KC_MS_R",
        "KC_MPLY", "KC_VOLD", "KC_VOLU", "KC_MUTE", "KC_NO", "U_NU", "KC_WH_L", "KC_WH_D", "KC_WH_U", "KC_WH_R",
        "U_NP", "U_NP", "U_NA", "U_NA", "U_NA", "KC_BTN2", "KC_BTN1", "KC_BTN3", "U_NP", "U_NP",
    ]

    // Derived from `users/manna-harbour_miryoku/miryoku_babel/miryoku_layer_alternatives.h` (MIRYOKU_ALTERNATIVES_MEDIA)
    static let mediaLayer40: [String] = [
        "TD(U_TD_BOOT)", "TD(U_TD_U_TAP)", "TD(U_TD_U_EXTRA)", "TD(U_TD_U_BASE)", "U_NA", "RGB_TOG", "RGB_MOD", "RGB_HUI", "RGB_SAI", "RGB_VAI",
        "KC_LGUI", "KC_LALT", "KC_LCTL", "KC_LSFT", "U_NA", "U_NU", "KC_MPRV", "KC_VOLD", "KC_VOLU", "KC_MNXT",
        "U_NA", "KC_ALGR", "TD(U_TD_U_FUN)", "TD(U_TD_U_MEDIA)", "U_NA", "OU_AUTO", "U_NU", "U_NU", "U_NU", "U_NU",
        "U_NP", "U_NP", "U_NA", "U_NA", "U_NA", "KC_MSTP", "KC_MPLY", "KC_MUTE", "U_NP", "U_NP",
    ]

    // Derived from `keyboards/silakka54/keymaps/manna-harbour_miryoku_enthium/config.h` (custom MIRYOKU_LAYER_NUM)
    static let numLayer40: [String] = [
        "KC_LBRC", "KC_7", "KC_8", "KC_9", "KC_RBRC", "U_NA", "TD(U_TD_U_BASE)", "TD(U_TD_U_EXTRA)", "TD(U_TD_U_TAP)", "TD(U_TD_BOOT)",
        "KC_W", "KC_SCLN", "KC_4", "KC_5", "KC_6", "U_NA", "KC_LSFT", "KC_LCTL", "KC_LALT", "KC_LGUI",
        "KC_GRV", "KC_1", "KC_2", "KC_3", "KC_BSLS", "U_NA", "TD(U_TD_U_NUM)", "TD(U_TD_U_NAV)", "KC_ALGR", "U_NA",
        "U_NP", "U_NP", "KC_DOT", "KC_0", "KC_MINS", "U_NA", "U_NA", "U_NA", "U_NP", "U_NP",
    ]

    // Derived from `users/manna-harbour_miryoku/miryoku_babel/miryoku_layer_alternatives.h` (MIRYOKU_ALTERNATIVES_FUN)
    static let funLayer40: [String] = [
        "KC_F12", "KC_F7", "KC_F8", "KC_F9", "KC_PSCR", "U_NA", "TD(U_TD_U_BASE)", "TD(U_TD_U_EXTRA)", "TD(U_TD_U_TAP)", "TD(U_TD_BOOT)",
        "KC_F11", "KC_F4", "KC_F5", "KC_F6", "KC_SCRL", "U_NA", "KC_LSFT", "KC_LCTL", "KC_LALT", "KC_LGUI",
        "KC_F10", "KC_F1", "KC_F2", "KC_F3", "KC_PAUS", "U_NA", "TD(U_TD_U_FUN)", "TD(U_TD_U_MEDIA)", "KC_ALGR", "U_NA",
        "U_NP", "U_NP", "KC_APP", "KC_SPC", "KC_TAB", "U_NA", "U_NA", "U_NA", "U_NP", "U_NP",
    ]
}
