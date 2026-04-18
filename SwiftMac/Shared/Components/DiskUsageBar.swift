import SwiftUI

struct DiskUsageBar: View {
    let usedBytes: Int64
    let totalBytes: Int64

    private var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ProgressView(value: progress)
                .tint(progress > 0.9 ? .red : progress > 0.75 ? .orange : .blue)
            HStack {
                Text(usedBytes.byteString + " used")
                Spacer()
                Text(totalBytes.byteString + " total")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
