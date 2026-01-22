import Foundation
import CoreFoundation
import IOKit.hid

final class RawHIDLayerListener {
    private let appState: AppState
    private var manager: IOHIDManager?
    private var deviceContexts: [IOHIDDevice: DeviceContext] = [:]

    // silakka54 USB IDs
    private let vendorID: Int = 0xFEED
    private let productID: Int = 0x1212

    // QMK Raw HID defaults
    private let usagePage: Int = 0xFF60
    private let usage: Int = 0x61

    init(appState: AppState) {
        self.appState = appState
    }

    func start() {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        self.manager = manager

        let matching: [String: Any] = [
            kIOHIDVendorIDKey as String: vendorID,
            kIOHIDProductIDKey as String: productID,
            kIOHIDPrimaryUsagePageKey as String: usagePage,
            kIOHIDPrimaryUsageKey as String: usage,
        ]

        IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)
        IOHIDManagerRegisterDeviceMatchingCallback(manager, deviceMatchedCallback, Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterDeviceRemovalCallback(manager, deviceRemovedCallback, Unmanaged.passUnretained(self).toOpaque())

        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue)
        let openResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        if openResult != kIOReturnSuccess {
            fputs("Failed to open IOHIDManager: \(openResult)\n", stderr)
        }
    }

    fileprivate func handleMatchedDevice(_ device: IOHIDDevice) {
        if deviceContexts[device] != nil { return }

        let openResult = IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeNone))
        if openResult != kIOReturnSuccess {
            fputs("Failed to open IOHIDDevice: \(openResult)\n", stderr)
            return
        }

        // Keep a buffer alive for the callback.
        let context = DeviceContext(bufferLength: 64)
        deviceContexts[device] = context

        IOHIDDeviceRegisterInputReportCallback(
            device,
            context.buffer,
            context.bufferLength,
            inputReportCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )

        IOHIDDeviceScheduleWithRunLoop(device, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue)
    }

    fileprivate func handleRemovedDevice(_ device: IOHIDDevice) {
        if let context = deviceContexts.removeValue(forKey: device) {
            _ = context
        }
        IOHIDDeviceUnscheduleFromRunLoop(device, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue)
        IOHIDDeviceClose(device, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    fileprivate func handleInputReport(_ report: [UInt8]) {
        // QMK Raw HID is 32 bytes, but some APIs include a leading Report ID byte.
        let payload: ArraySlice<UInt8>
        if report.count >= 33, report[0] == 0x00 {
            payload = report[1...]
        } else {
            payload = report[...]
        }

        guard payload.count >= 4 else { return }
        let bytes = Array(payload.prefix(32))

        // byte[0] = message type, 'L' (0x4C)
        guard bytes[0] == 0x4C else { return }
        // byte[1] = version
        guard bytes[1] == 0x01 else { return }

        let highestLayer = Int(bytes[2])
        DispatchQueue.main.async { [appState] in
            appState.setCurrentLayerIndex(highestLayer)
        }
    }
}

private final class DeviceContext {
    let bufferLength: CFIndex
    let buffer: UnsafeMutablePointer<UInt8>

    init(bufferLength: Int) {
        self.bufferLength = CFIndex(bufferLength)
        self.buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferLength)
        self.buffer.initialize(repeating: 0, count: bufferLength)
    }

    deinit {
        buffer.deinitialize(count: Int(bufferLength))
        buffer.deallocate()
    }
}

private func deviceMatchedCallback(context: UnsafeMutableRawPointer?, result: IOReturn, sender: UnsafeMutableRawPointer?, device: IOHIDDevice!) {
    guard let context else { return }
    let listener = Unmanaged<RawHIDLayerListener>.fromOpaque(context).takeUnretainedValue()
    listener.handleMatchedDevice(device)
}

private func deviceRemovedCallback(context: UnsafeMutableRawPointer?, result: IOReturn, sender: UnsafeMutableRawPointer?, device: IOHIDDevice!) {
    guard let context else { return }
    let listener = Unmanaged<RawHIDLayerListener>.fromOpaque(context).takeUnretainedValue()
    listener.handleRemovedDevice(device)
}

private func inputReportCallback(context: UnsafeMutableRawPointer?, result: IOReturn, sender: UnsafeMutableRawPointer?, type: IOHIDReportType, reportID: UInt32, report: UnsafeMutablePointer<UInt8>, reportLength: Int) {
    guard let context else { return }
    guard reportLength > 0 else { return }

    let listener = Unmanaged<RawHIDLayerListener>.fromOpaque(context).takeUnretainedValue()
    let bytes = Array(UnsafeBufferPointer(start: report, count: reportLength))
    listener.handleInputReport(bytes)
}
