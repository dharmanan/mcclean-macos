import Foundation
import SwiftUI

@MainActor
final class PrivacyCleanerViewModel: ObservableObject {
    @Published var items: [FileItem] = []
    @Published var isScanning = false

    var totalSize: Int64 {
        items.reduce(0) { $0 + $1.size }
    }

    func scan() async {
        guard !isScanning else { return }
        isScanning = true
        defer { isScanning = false }
        items = (try? await PrivacyScanner().scan()) ?? []
    }

    func clean() async {
        _ = await CleanEngine.shared.clean(items: items) { _, _ in }
        items.removeAll()
    }
}
