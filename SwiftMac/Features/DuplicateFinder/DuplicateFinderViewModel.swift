import Foundation
import SwiftUI

@MainActor
final class DuplicateFinderViewModel: ObservableObject {
    @Published var duplicates: [FileItem] = []
    @Published var isScanning = false

    var totalSize: Int64 {
        duplicates.reduce(0) { $0 + $1.size }
    }

    func scan() async {
        guard !isScanning else { return }
        isScanning = true
        defer { isScanning = false }
        duplicates = (try? await DuplicateScanner().scan()) ?? []
    }
}
