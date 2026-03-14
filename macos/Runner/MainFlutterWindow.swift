import Cocoa
import FlutterMacOS
import window_manager

class MainFlutterWindow: NSWindow {
    override func awakeFromNib() {
        // Create Flutter view controller
        let flutterViewController = FlutterViewController()

        // Keep current window size
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        // Register plugins
        RegisterGeneratedPlugins(registry: flutterViewController)

        // ---- CUSTOM WINDOW SETTINGS ----

        // Hide title bar text
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true

        // Make background transparent
        self.isOpaque = false
        self.backgroundColor = NSColor.clear

        // Allow full-size content behind title bar
        self.styleMask.insert(.fullSizeContentView)

        // ---- WINDOW SIZE SETTINGS ----

        // Set minimum size to prevent UI collapse
        self.minSize = NSSize(width: 1000, height: 600)


        super.awakeFromNib()
    }
}
