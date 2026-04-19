import SwiftUI
import SwiftData

@main
struct SwiftMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([ScanHistory.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallback])
            } catch {
                fatalError("Unable to create SwiftData container: \(error.localizedDescription)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .modelContainer(sharedModelContainer)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandMenu("Scan") {
                Button("Start Smart Scan") {
                    NotificationCenter.default.post(name: .startScan, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }

        MenuBarExtra("SwiftMac", systemImage: "sparkles") {
            MenuBarView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
        }
    }
}

extension Notification.Name {
    static let startScan = Notification.Name("startScan")
}
