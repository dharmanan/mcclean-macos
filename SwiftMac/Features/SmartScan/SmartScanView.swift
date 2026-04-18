import SwiftUI

struct SmartScanView: View {
    @StateObject private var viewModel = SmartScanViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart Scan")
                        .font(.title2.bold())
                    Text(viewModel.totalFound.byteString + " found across \(viewModel.categories.count) categories")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(viewModel.isScanning ? "Scanning..." : "Start Scan") {
                    Task { await viewModel.scan() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isScanning)
            }

            List {
                ForEach(viewModel.categories) { category in
                    Section(category.type.rawValue) {
                        ForEach(category.items.prefix(10)) { item in
                            FileListRow(item: item)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
