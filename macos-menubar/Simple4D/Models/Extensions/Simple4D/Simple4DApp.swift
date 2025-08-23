import SwiftUI
import AppKit

@main
struct Simple4DApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var hotKeyManager: HotKeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "4D Capture")
        statusItem?.button?.action = #selector(statusBarButtonClicked(_:))
        statusItem?.button?.target = self
        statusItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // Create popover
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(rootView: MenuBarView())
        popover?.behavior = .transient

        // Set up global hotkey (Cmd+Shift+Space)
        hotKeyManager = HotKeyManager()
        hotKeyManager?.delegate = self
        if !(hotKeyManager?.registerHotKey() ?? false) {
            print("Failed to register global hotkey")
        }
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            // Right click - show context menu
            showContextMenu()
        } else {
            // Left click - toggle popover
            togglePopover()
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        let quitItem = NSMenuItem(title: "Quit Simple4D", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.popUpMenu(menu)
    }

    @objc func togglePopover() {
        guard let statusButton = statusItem?.button else { return }

        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
                // Focus the text field when shown via hotkey
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

extension AppDelegate: HotKeyDelegate {
    func hotKeyPressed() {
        togglePopover()
    }
}

