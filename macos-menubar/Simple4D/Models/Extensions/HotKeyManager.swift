//
//  HotKeyManager.swift
//  Simple4D
//
//  Created by Prabodh Agarwal on 22/08/25.
//


  import Cocoa
  import Carbon

  class HotKeyManager {
      private var hotKeyRef: EventHotKeyRef?
      private let hotKeyID = EventHotKeyID(signature: OSType(0x4D4B4854), id: 1) // 'MKHT'

      weak var delegate: HotKeyDelegate?

      func registerHotKey() -> Bool {
          let modifiers = UInt32(cmdKey | shiftKey) // Cmd+Shift
          let keyCode = UInt32(kVK_Space) // Space key

          var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))

          let status = RegisterEventHotKey(
              keyCode,
              modifiers,
              hotKeyID,
              GetEventDispatcherTarget(),
              0,
              &hotKeyRef
          )

          if status == noErr {
              // Install event handler
              var eventHandler: EventHandlerRef?
              InstallEventHandler(
                  GetEventDispatcherTarget(),
                  { (_, event, userData) -> OSStatus in
                      if let userData = userData {
                          let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                          manager.delegate?.hotKeyPressed()
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
          if let hotKeyRef = hotKeyRef {
              UnregisterEventHotKey(hotKeyRef)
              self.hotKeyRef = nil
          }
      }

      deinit {
          unregisterHotKey()
      }
  }

  protocol HotKeyDelegate: AnyObject {
      func hotKeyPressed()
  }
