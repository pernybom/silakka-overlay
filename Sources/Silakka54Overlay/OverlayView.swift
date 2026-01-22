import AppKit

final class OverlayView: NSView {
    private let layout: Silakka54Layout
    private let keymap: Silakka54MiryokuEnthiumKeymap

    private var layerIndex: Int = 0 {
        didSet { needsDisplay = true }
    }

    private let unit: CGFloat = 39
    private let padding: CGFloat = 10
    private let keyCornerRadius: CGFloat = 6

    init(layout: Silakka54Layout, keymap: Silakka54MiryokuEnthiumKeymap) {
        self.layout = layout
        self.keymap = keymap

        let frame = layout.boundingRect(unit: unit, padding: padding)
        super.init(frame: frame)
        wantsLayer = true
        layer?.masksToBounds = false
    }

    required init?(coder: NSCoder) {
        return nil
    }

    var initialFrame: CGRect {
        frame.offsetBy(dx: 40, dy: 80)
    }

    func setLayerIndex(_ index: Int) {
        layerIndex = index
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()

        let backgroundPath = NSBezierPath(roundedRect: bounds, xRadius: 10, yRadius: 10)
        NSColor(calibratedWhite: 0.05, alpha: 0.70).setFill()
        backgroundPath.fill()

        drawLayerLabel()

        let labels = keymap.labelsForLayerIndex(layerIndex)
        let maxY = layout.maxY
        for (idx, key) in layout.keys.enumerated() {
            let rect = key.rect(unit: unit, padding: padding, maxY: maxY)
            drawKey(rect: rect, label: idx < labels.count ? labels[idx] : "")
        }
    }

    private func drawLayerLabel() {
        let name = keymap.layerName(for: layerIndex)
        let text = "Layer: \(name)"

        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: NSColor(calibratedWhite: 1.0, alpha: 0.9),
        ]

        let textRect = CGRect(x: padding, y: bounds.height - padding - 16, width: bounds.width - 2 * padding, height: 16)
        (text as NSString).draw(in: textRect, withAttributes: attrs)
    }

    private func drawKey(rect: CGRect, label: String) {
        let path = NSBezierPath(roundedRect: rect, xRadius: keyCornerRadius, yRadius: keyCornerRadius)

        NSColor(calibratedWhite: 0.15, alpha: 0.80).setFill()
        path.fill()

        NSColor(calibratedWhite: 1.0, alpha: 0.20).setStroke()
        path.lineWidth = 1
        path.stroke()

        guard !label.isEmpty else { return }

        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: NSColor(calibratedWhite: 1.0, alpha: 0.95),
            .paragraphStyle: {
                let p = NSMutableParagraphStyle()
                p.alignment = .center
                p.lineBreakMode = .byTruncatingMiddle
                return p
            }(),
        ]

        let inset = rect.insetBy(dx: 2, dy: 5)
        (label as NSString).draw(in: inset, withAttributes: attrs)
    }
}
