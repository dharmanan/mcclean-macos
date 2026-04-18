import SwiftUI

struct SettingsView: View {
    @StateObject private var scheduler = SchedulerService.shared
    @AppStorage("autoClean") private var autoClean = false
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("largeFileMB") private var largeFileMB = 100

    var body: some View {
        TabView {
            Form {
                Section("Behavior") {
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                }
                Section("Large Files Threshold") {
                    Stepper("Minimum: \(largeFileMB) MB", value: $largeFileMB, in: 10...10000, step: 10)
                }
            }
            .tabItem { Label("General", systemImage: "gear") }

            Form {
                Section("Scheduled Cleaning") {
                    Toggle("Enable", isOn: $scheduler.isEnabled)
                    if scheduler.isEnabled {
                        Picker("Interval", selection: $scheduler.interval) {
                            ForEach(SchedulerService.CleaningInterval.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        Toggle("Auto-clean after scan", isOn: $autoClean)
                    }
                }
            }
            .tabItem { Label("Schedule", systemImage: "clock") }

            VStack(spacing: 12) {
                Image(systemName: "sparkles").font(.system(size: 56)).foregroundStyle(.blue)
                Text("SwiftMac").font(.largeTitle.bold())
                Text("Version 1.0.0").foregroundStyle(.secondary)
                Text("Free & Open Source\nZero Telemetry · MIT License")
                    .multilineTextAlignment(.center).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 400, height: 260)
    }
}
