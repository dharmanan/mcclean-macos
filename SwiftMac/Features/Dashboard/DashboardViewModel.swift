import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var categories: [ScanCategory] = []
    @Published var scanState: ScanState = .idle
    @Published var totalFound: Int64 = 0
    @Published var totalCleaned: Int64 = 0
    @Published var scanProgress: Double = 0

    enum ScanState { case idle, scanning, done, cleaning }

    private let totalCats = 8
    private var count = 0

    func startScan() async {
        guard scanState == .idle || scanState == .done else { return }
        categories = []; scanState = .scanning; totalFound = 0; scanProgress = 0; count = 0
        do {
            let results = try await ScanEngine.shared.scanAll { _, cat in
                categories.append(cat); count += 1
                scanProgress = Double(count) / Double(totalCats)
                totalFound += cat.totalSize
            }
            categories = results; scanState = .done
        } catch { scanState = .idle }
    }

    func cleanSelected() async {
        scanState = .cleaning
        let items = categories.flatMap { $0.items }
        let (_, _, freed) = await CleanEngine.shared.clean(items: items) { _, _ in }
        totalCleaned = freed
        for i in categories.indices {
            categories[i].items.removeAll { !FileManager.default.fileExists(atPath: $0.url.path) }
            categories[i].totalSize = categories[i].items.reduce(0) { $0 + $1.size }
        }
        totalFound = categories.reduce(0) { $0 + $1.totalSize }
        scanState = .done
    }
}
