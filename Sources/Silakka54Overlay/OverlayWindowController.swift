import AppKit

final class OverlayWindowController {
    private let appState: AppState
    private let keymap = Silakka54MiryokuEnthiumKeymap()
    private let layout = Silakka54Layout.loadFromQMKRepo() ?? .fallback

    private var window: NSPanel?
    private var layerObserverID: UUID?
    private var isClickThrough = true

    init(appState: AppState) {
        self.appState = appState
    }

    func show() {
        let overlayView = OverlayView(layout: layout, keymap: keymap)
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        let panel = NSPanel(
            contentRect: overlayView.initialFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = !isClickThrough
        panel.ignoresMouseEvents = isClickThrough

        panel.contentView = overlayView
        panel.setFrame(overlayView.initialFrame, display: true)
        panel.orderFrontRegardless()

        self.window = panel

        layerObserverID = appState.observeLayerChanges { [weak overlayView] layerIndex in
            overlayView?.setLayerIndex(layerIndex)
        }
    }

    func toggleClickThrough() {
        isClickThrough.toggle()
        window?.ignoresMouseEvents = isClickThrough
        window?.isMovableByWindowBackground = !isClickThrough
    }

    deinit {
        if let id = layerObserverID {
            appState.removeObserver(id)
        }
    }
}
