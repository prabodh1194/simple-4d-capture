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
    var dashboardWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "square.grid.2x2", accessibilityDescription: "4D Capture")
        statusItem?.button?.action = #selector(statusBarButtonClicked(_:))
        statusItem?.button?.target = self
        statusItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // Create popover with dashboard callback
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(rootView: MenuBarView(onOpenDashboard: openDashboard))
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
        
        let dashboardItem = NSMenuItem(title: "Open Dashboard", action: #selector(openDashboard), keyEquivalent: "d")
        dashboardItem.target = self
        menu.addItem(dashboardItem)
        
        menu.addItem(NSMenuItem.separator())
        
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
    
    @objc func openDashboard() {
        // Close popover if open
        popover?.performClose(nil)
        
        // Create or show dashboard window
        if dashboardWindow == nil {
            let dashboardView = DashboardView()
            let hostingController = NSHostingController(rootView: dashboardView)
            
            dashboardWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .resizable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            dashboardWindow?.contentViewController = hostingController
            dashboardWindow?.title = "4D Dashboard"
            dashboardWindow?.center()
            dashboardWindow?.setFrameAutosaveName("DashboardWindow")
            
            // Handle window closing
            dashboardWindow?.delegate = DashboardWindowDelegate { [weak self] in
                self?.dashboardWindow = nil
            }
        }
        
        dashboardWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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

class DashboardWindowDelegate: NSObject, NSWindowDelegate {
    private let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init()
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}

