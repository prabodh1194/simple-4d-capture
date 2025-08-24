//
//  HotKeyManager.swift
//  Simple4D
//
//  Created by Prabodh Agarwal on 22/08/25.
//

import Carbon
import Cocoa

class HotKeyManager {
    private var captureHotKeyRef: EventHotKeyRef?
    private let captureHotKeyID = EventHotKeyID(signature: OSType(0x4D4B_4854), id: 1) // 'MKHT'

    weak var delegate: HotKeyDelegate?

    func registerHotKey() -> Bool {
        registerCaptureHotKey()
    }

    private func registerCaptureHotKey() -> Bool {
        let modifiers = UInt32(cmdKey | shiftKey) // Cmd+Shift
        let keyCode = UInt32(kVK_Space) // Space key

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            captureHotKeyID,
            GetEventDispatcherTarget(),
            0,
            &captureHotKeyRef
        )

        if status == noErr {
            // Install event handler
            var eventHandler: EventHandlerRef?
            InstallEventHandler(
                GetEventDispatcherTarget(),
                { _, event, userData -> OSStatus in
                    if let userData = userData, let event = event {
                        let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()

                        // Get the hotkey ID from the event
                        var hotKeyID = EventHotKeyID()
                        GetEventParameter(
                            event,
                            EventParamName(kEventParamDirectObject),
                            EventParamType(typeEventHotKeyID),
                            nil,
                            MemoryLayout<EventHotKeyID>.size,
                            nil,
                            &hotKeyID
                        )

                        if hotKeyID.id == manager.captureHotKeyID.id {
                            manager.delegate?.captureHotKeyPressed()
                        }
                    }
                    return noErr
                },
                1,
                &eventType,
                Unmanaged.passUnretained(self).toOpaque(),
                &eventHandler
            )

            return true
        }

        return false
    }

    func unregisterHotKey() {
        if let captureHotKeyRef = captureHotKeyRef {
            UnregisterEventHotKey(captureHotKeyRef)
            self.captureHotKeyRef = nil
        }
    }

    deinit {
        unregisterHotKey()
    }
}

protocol HotKeyDelegate: AnyObject {
    func captureHotKeyPressed()
}
