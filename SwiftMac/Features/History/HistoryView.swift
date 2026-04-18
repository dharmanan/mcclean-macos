import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(sort: \ScanHistory.date, order: .reverse) private var history: [ScanHistory]
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scan History")
                .font(.title2.bold())

            HStack(spacing: 24) {
                Text("Scanned: " + viewModel.totalScanned(in: history).byteString)
                Text("Cleaned: " + viewModel.totalCleaned(in: history).byteString)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            List(history) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    Text(entry.displayCleaned + " cleaned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}
