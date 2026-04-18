import SwiftUI

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @State private var selectedCategory: ScanCategory?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedCategory) {
                Section("Overview") {
                    NavigationLink {
                        SmartScanView()
                    } label: {
                        Label("Smart Scan", systemImage: "sparkles")
                    }
                    NavigationLink {
                        DiskMapView()
                    } label: {
                        Label("Disk Map", systemImage: "chart.treemap")
                    }
                    NavigationLink {
                        LoginItemsView()
                    } label: {
                        Label("Login Items", systemImage: "bolt.circle")
                    }
                }
                if !vm.categories.isEmpty {
                    Section("Last Scan") {
                        ForEach(vm.categories) { cat in
                            CategoryRow(category: cat).tag(cat)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("SwiftMac")
            .toolbar {
                ToolbarItem {
                    Button {
                        Task { await vm.startScan() }
                    } label: {
                        Label(vm.scanState == .scanning ? "Scanning..." : "Smart Scan",
                              systemImage: "sparkles")
                    }
                    .disabled(vm.scanState == .scanning || vm.scanState == .cleaning)
                }
            }
        } detail: {
            ScanOverview(vm: vm)
        }
        .onReceive(NotificationCenter.default.publisher(for: .startScan)) { _ in
            Task { await vm.startScan() }
        }
    }
}

struct ScanOverview: View {
    @ObservedObject var vm: DashboardViewModel
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                ProgressRing(progress: vm.scanProgress, size: 180)
                VStack(spacing: 4) {
                    if vm.scanState == .scanning {
                        ProgressView()
                        Text("Scanning...").font(.caption)
                    } else if vm.scanState == .done {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 40)).foregroundStyle(.green)
                        Text(vm.totalFound.byteString).font(.title2.bold())
                        Text("found").font(.caption).foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "sparkles").font(.system(size: 40))
                        Text("Tap Scan to begin").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            if vm.scanState == .done && vm.totalFound > 0 {
                Button { Task { await vm.cleanSelected() } } label: {
                    Label("Clean \(vm.totalFound.byteString)", systemImage: "trash")
                        .font(.headline).padding(.horizontal, 24).padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent).tint(.red)
            }
            Spacer()
            HStack(spacing: 40) {
                VStack { Text("\(vm.categories.count)").font(.headline); Text("Categories").font(.caption).foregroundStyle(.secondary) }
                VStack { Text(vm.totalFound.byteString).font(.headline); Text("Found").font(.caption).foregroundStyle(.secondary) }
                VStack { Text(vm.totalCleaned.byteString).font(.headline); Text("Cleaned").font(.caption).foregroundStyle(.secondary) }
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
