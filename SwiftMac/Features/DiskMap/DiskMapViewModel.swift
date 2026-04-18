import Foundation
import SwiftUI

struct DiskMapItem: Identifiable {
    let id = UUID()
    let name: String
    let size: Int64
    let color: Color
}

@MainActor
final class DiskMapViewModel: ObservableObject {
    @Published var items: [DiskMapItem] = []
    @Published var totalUsed: Int64 = 0
    @Published var totalCapacity: Int64 = 0

    func load() async {
        let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        let total = (attributes?[.systemSize] as? Int64) ?? 0
        let free = (attributes?[.systemFreeSize] as? Int64) ?? 0
        totalCapacity = total
        totalUsed = max(0, total - free)

        let paths: [(String, String, Color)] = [
            ("Applications", "/Applications", .blue),
            ("Library", "~/Library", .purple),
            ("Documents", "~/Documents", .orange),
            ("Downloads", "~/Downloads", .green),
            ("Desktop", "~/Desktop", .pink)
        ]

        items = paths.map { name, rawPath, color in
            let expanded = (rawPath as NSString).expandingTildeInPath
            let size = FileManager.default.directorySize(at: URL(fileURLWithPath: expanded))
            return DiskMapItem(name: name, size: size, color: color)
        }
        .filter { $0.size > 0 }
        .sorted { $0.size > $1.size }
    }
}
