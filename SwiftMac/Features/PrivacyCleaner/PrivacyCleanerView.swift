import SwiftUI

struct PrivacyCleanerView: View {
    @StateObject private var viewModel = PrivacyCleanerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Privacy Cleaner")
                        .font(.title2.bold())
                    Text(viewModel.totalSize.byteString + " removable privacy data")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(viewModel.isScanning ? "Scanning..." : "Scan") {
                    Task { await viewModel.scan() }
                }
                .buttonStyle(.bordered)

                Button("Clean") {
                    Task { await viewModel.clean() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.items.isEmpty)
            }

            List(viewModel.items) { item in
                FileListRow(item: item)
            }
        }
        .padding()
    }
}
