import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    func totalCleaned(in entries: [ScanHistory]) -> Int64 {
        entries.reduce(0) { $0 + $1.totalCleaned }
    }

    func totalScanned(in entries: [ScanHistory]) -> Int64 {
        entries.reduce(0) { $0 + $1.totalScanned }
    }
}
