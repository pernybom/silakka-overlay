import AppKit

struct LaunchOptions {
    let noUI: Bool
    let logLayers: Bool

    static func parse(_ args: [String]) -> LaunchOptions {
        let noUI = args.contains("--no-ui")
        let logLayers = args.contains("--log-layers") || noUI
        return LaunchOptions(noUI: noUI, logLayers: logLayers)
    }
}

final class AppState {
    var overlayController: OverlayWindowController?
    var hidListener: RawHIDLayerListener?
    var menuController: MenuController?

    private(set) var currentLayerIndex: Int = 0 {
        didSet { notify() }
    }

    func setCurrentLayerIndex(_ value: Int) {
        guard value != currentLayerIndex else { return }
        currentLayerIndex = value
    }

    private var observers: [UUID: (Int) -> Void] = [:]

    func observeLayerChanges(_ handler: @escaping (Int) -> Void) -> UUID {
        let id = UUID()
        observers[id] = handler
        handler(currentLayerIndex)
        return id
    }

    func removeObserver(_ id: UUID) {
        observers.removeValue(forKey: id)
    }

    private func notify() {
        for handler in observers.values {
            handler(currentLayerIndex)
        }
    }
}

let app = NSApplication.shared

final class MenuController: NSObject {
    private let appState: AppState
    private var statusItem: NSStatusItem?

    init(appState: AppState) {
        self.appState = appState
    }

    func install() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "Silakka54"

        let menu = NSMenu()

        let toggleClickThrough = NSMenuItem(title: "Toggle Click-Through", action: #selector(toggleClickThroughAction), keyEquivalent: "")
        toggleClickThrough.target = self

        let quit = NSMenuItem(title: "Quit", action: #selector(quitAction), keyEquivalent: "")
        quit.target = self

        menu.addItem(toggleClickThrough)
        menu.addItem(.separator())
        menu.addItem(quit)

        item.menu = menu
        self.statusItem = item
    }

    @objc private func quitAction() {
        NSApp.terminate(nil)
    }

    @objc private func toggleClickThroughAction() {
        appState.overlayController?.toggleClickThrough()
    }
}

enum Logger {
    static func log(_ s: String) {
        guard let data = (s + "\n").data(using: .utf8) else { return }
        FileHandle.standardError.write(data)
    }
}

let options = LaunchOptions.parse(CommandLine.arguments)
let appState = AppState()

if options.noUI {
    app.setActivationPolicy(.prohibited)
} else {
    app.setActivationPolicy(.accessory)
    let menu = MenuController(appState: appState)
    menu.install()
    appState.menuController = menu
}

if !options.noUI {
    let overlayController = OverlayWindowController(appState: appState)
    overlayController.show()
    appState.overlayController = overlayController
}

let hidListener = RawHIDLayerListener(appState: appState)
hidListener.start()
appState.hidListener = hidListener

if options.logLayers {
    let keymap = Silakka54MiryokuEnthiumKeymap()
    _ = appState.observeLayerChanges { layerIndex in
        Logger.log("Layer \(layerIndex): \(keymap.layerName(for: layerIndex))")
    }
}

app.run()
