import SwiftUI

struct DiskMapView: View {
    @StateObject private var viewModel = DiskMapViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Disk Map")
                .font(.title2.bold())

            DiskUsageBar(usedBytes: viewModel.totalUsed, totalBytes: viewModel.totalCapacity)

            TreemapView(items: viewModel.items)
                .frame(height: 280)

            List(viewModel.items) { item in
                HStack {
                    Label(item.name, systemImage: "square.fill")
                        .foregroundStyle(item.color)
                    Spacer()
                    Text(item.size.byteString)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .task {
            await viewModel.load()
        }
    }
}
