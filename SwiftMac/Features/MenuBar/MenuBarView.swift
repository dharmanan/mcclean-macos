import SwiftUI

struct MenuBarView: View {
    @State private var diskFree: Int64 = 0
    @State private var diskTotal: Int64 = 0
    @State private var isScanning = false

    var usage: Double { diskTotal > 0 ? Double(diskTotal - diskFree) / Double(diskTotal) : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Disk Usage").font(.headline)
                    Spacer()
                    Text(diskFree.byteString + " free").font(.caption).foregroundStyle(.secondary)
                }
                ProgressView(value: usage)
                    .tint(usage > 0.9 ? .red : usage > 0.7 ? .orange : .blue)
            }
            .padding([.horizontal, .top])
            Divider()
            Button { Task { isScanning = true; _ = try? await ScanEngine.shared.scanAll { _,_ in }; isScanning = false } } label: {
                Label(isScanning ? "Scanning..." : "Quick Scan", systemImage: "sparkles").frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(isScanning).padding(.horizontal)
            Divider()
            Button("Open SwiftMac") { NSApp.activate(ignoringOtherApps: true) }.padding(.horizontal)
            Button("Settings") { NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil) }.padding(.horizontal)
            Divider()
            Button("Quit") { NSApp.terminate(nil) }.padding(.horizontal).padding(.bottom)
        }
        .frame(width: 260)
        .task { loadDisk() }
    }

    private func loadDisk() {
        let a = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        diskTotal = (a?[.systemSize] as? Int64) ?? 0
        diskFree  = (a?[.systemFreeSize] as? Int64) ?? 0
    }
}
