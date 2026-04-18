import Foundation
import SwiftUI

@MainActor
final class SmartScanViewModel: ObservableObject {
    @Published var categories: [ScanCategory] = []
    @Published var isScanning = false
    @Published var totalFound: Int64 = 0

    func scan() async {
        guard !isScanning else { return }
        isScanning = true
        categories = []
        totalFound = 0

        defer { isScanning = false }

        do {
            let results = try await ScanEngine.shared.scanAll { _, category in
                self.categories.append(category)
                self.totalFound += category.totalSize
            }
            categories = results
            totalFound = results.reduce(0) { $0 + $1.totalSize }
        } catch {
            categories = []
            totalFound = 0
        }
    }
}
