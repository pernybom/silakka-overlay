import Foundation

struct Silakka54Layout {
    struct Key {
        var x: Double
        var y: Double
        var w: Double
        var h: Double

        func rect(unit: CGFloat, padding: CGFloat, maxY: Double) -> CGRect {
            // QMK layout coordinates use y=0 at the top; AppKit's origin is bottom-left.
            // Flip vertically so the top row is drawn at the top, and the thumb row at the bottom.
            let flippedY = maxY - (y + h)
            return CGRect(
                x: padding + CGFloat(x) * unit,
                y: padding + CGFloat(flippedY) * unit,
                width: CGFloat(w) * unit,
                height: CGFloat(h) * unit
            )
        }
    }

    var keys: [Key]

    var maxY: Double {
        keys.map { $0.y + $0.h }.max() ?? 0
    }

    func boundingRect(unit: CGFloat, padding: CGFloat) -> CGRect {
        let maxX = keys.map { $0.x + $0.w }.max() ?? 0
        let width = padding * 2 + CGFloat(maxX) * unit
        let height = padding * 2 + CGFloat(self.maxY) * unit + 22
        return CGRect(x: 0, y: 0, width: width, height: height)
    }

    static let fallback: Silakka54Layout = {
        let unitKeys: [Key] = [
            // Row 0 (12)
            Key(x: 0, y: 0, w: 1, h: 1), Key(x: 1, y: 0, w: 1, h: 1), Key(x: 2, y: 0, w: 1, h: 1), Key(x: 3, y: 0, w: 1, h: 1), Key(x: 4, y: 0, w: 1, h: 1), Key(x: 5, y: 0, w: 1, h: 1),
            Key(x: 7, y: 0, w: 1, h: 1), Key(x: 8, y: 0, w: 1, h: 1), Key(x: 9, y: 0, w: 1, h: 1), Key(x: 10, y: 0, w: 1, h: 1), Key(x: 11, y: 0, w: 1, h: 1), Key(x: 12, y: 0, w: 1, h: 1),
            // Row 1 (12)
            Key(x: 0, y: 1, w: 1, h: 1), Key(x: 1, y: 1, w: 1, h: 1), Key(x: 2, y: 1, w: 1, h: 1), Key(x: 3, y: 1, w: 1, h: 1), Key(x: 4, y: 1, w: 1, h: 1), Key(x: 5, y: 1, w: 1, h: 1),
            Key(x: 7, y: 1, w: 1, h: 1), Key(x: 8, y: 1, w: 1, h: 1), Key(x: 9, y: 1, w: 1, h: 1), Key(x: 10, y: 1, w: 1, h: 1), Key(x: 11, y: 1, w: 1, h: 1), Key(x: 12, y: 1, w: 1, h: 1),
            // Row 2 (12)
            Key(x: 0, y: 2, w: 1, h: 1), Key(x: 1, y: 2, w: 1, h: 1), Key(x: 2, y: 2, w: 1, h: 1), Key(x: 3, y: 2, w: 1, h: 1), Key(x: 4, y: 2, w: 1, h: 1), Key(x: 5, y: 2, w: 1, h: 1),
            Key(x: 7, y: 2, w: 1, h: 1), Key(x: 8, y: 2, w: 1, h: 1), Key(x: 9, y: 2, w: 1, h: 1), Key(x: 10, y: 2, w: 1, h: 1), Key(x: 11, y: 2, w: 1, h: 1), Key(x: 12, y: 2, w: 1, h: 1),
            // Row 3 (12)
            Key(x: 0, y: 3, w: 1, h: 1), Key(x: 1, y: 3, w: 1, h: 1), Key(x: 2, y: 3, w: 1, h: 1), Key(x: 3, y: 3, w: 1, h: 1), Key(x: 4, y: 3, w: 1, h: 1), Key(x: 5, y: 3, w: 1, h: 1),
            Key(x: 7, y: 3, w: 1, h: 1), Key(x: 8, y: 3, w: 1, h: 1), Key(x: 9, y: 3, w: 1, h: 1), Key(x: 10, y: 3, w: 1, h: 1), Key(x: 11, y: 3, w: 1, h: 1), Key(x: 12, y: 3, w: 1, h: 1),
            // Row 4 (6)
            Key(x: 3, y: 4, w: 1, h: 1), Key(x: 4, y: 4, w: 1, h: 1), Key(x: 5, y: 4, w: 1, h: 1),
            Key(x: 7, y: 4, w: 1, h: 1), Key(x: 8, y: 4, w: 1, h: 1), Key(x: 9, y: 4, w: 1, h: 1),
        ]
        return Silakka54Layout(keys: unitKeys)
    }()

    static func loadFromQMKRepo() -> Silakka54Layout? {
        guard let qmkHome = findQMKHome() else { return nil }
        let path = (qmkHome as NSString).appendingPathComponent("keyboards/silakka54/keyboard.json")
        guard FileManager.default.fileExists(atPath: path) else { return nil }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let layouts = root?["layouts"] as? [String: Any]
            let layoutDef = layouts?["LAYOUT"] as? [String: Any]
            let layoutArr = layoutDef?["layout"] as? [[String: Any]] ?? []

            var keys: [Key] = layoutArr.compactMap { item in
                guard let x = item["x"] as? Double, let y = item["y"] as? Double else { return nil }
                let w = item["w"] as? Double ?? 1
                let h = item["h"] as? Double ?? 1
                return Key(x: x, y: y, w: w, h: h)
            }
            guard keys.count == 54 else { return nil }
            keys.sort { a, b in
                if a.y != b.y { return a.y < b.y }
                return a.x < b.x
            }
            return Silakka54Layout(keys: keys)
        } catch {
            return nil
        }
    }

    private static func findQMKHome() -> String? {
        var current = FileManager.default.currentDirectoryPath
        for _ in 0..<10 {
            let candidate = (current as NSString).appendingPathComponent("keyboards/silakka54/keyboard.json")
            if FileManager.default.fileExists(atPath: candidate) {
                return current
            }
            let parent = (current as NSString).deletingLastPathComponent
            if parent == current { break }
            current = parent
        }
        return nil
    }
}
