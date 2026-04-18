import Foundation
import SwiftData

@Model
final class ScanHistory {
    var date: Date
    var totalScanned: Int64
    var totalCleaned: Int64
    var categories: [String]
    var durationSeconds: Double

    init(date: Date = .now, totalScanned: Int64, totalCleaned: Int64,
         categories: [String], durationSeconds: Double) {
        self.date = date
        self.totalScanned = totalScanned
        self.totalCleaned = totalCleaned
        self.categories = categories
        self.durationSeconds = durationSeconds
    }

    var displayScanned: String { ByteCountFormatter.string(fromByteCount: totalScanned, countStyle: .file) }
    var displayCleaned: String { ByteCountFormatter.string(fromByteCount: totalCleaned, countStyle: .file) }
}
