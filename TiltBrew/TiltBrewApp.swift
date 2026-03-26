import SwiftUI
import AppKit

@main
struct TiltBrewApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var accelerometer = Accelerometer()

    var body: some Scene {
        WindowGroup {
            ContentView(accelerometer: accelerometer)
                .frame(width: 400, height: 540)
                .onAppear {
                    accelerometer.start()
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
