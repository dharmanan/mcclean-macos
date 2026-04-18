import SwiftUI

struct DuplicateFinderView: View {
    @StateObject private var viewModel = DuplicateFinderViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duplicate Finder")
                        .font(.title2.bold())
                    Text(viewModel.totalSize.byteString + " reclaimable")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(viewModel.isScanning ? "Scanning..." : "Scan") {
                    Task { await viewModel.scan() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isScanning)
            }

            List(viewModel.duplicates) { item in
                FileListRow(item: item)
            }
        }
        .padding()
    }
}
