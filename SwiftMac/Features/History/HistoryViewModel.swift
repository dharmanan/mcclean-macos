import Foundation

extension Collection where Element == ScanHistory {
    var totalCleanedBytes: Int64 {
        reduce(0) { $0 + $1.totalCleaned }
    }

    var totalScannedBytes: Int64 {
        reduce(0) { $0 + $1.totalScanned }
    }
}
