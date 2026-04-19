import Foundation
import SwiftUI

struct DiskMapItem: Identifiable {
    let id = UUID()
    let name: String
    let size: Int64
    let color: Color
}

private struct DiskMapPathSpec: Sendable {
    let name: String
    let rawPath: String
    let colorKey: String
}

private struct MeasuredDiskMapPath: Sendable {
    let name: String
    let size: Int64
    let colorKey: String
}

@MainActor
final class DiskMapViewModel: ObservableObject {
    @Published var items: [DiskMapItem] = []
    @Published var totalUsed: Int64 = 0
    @Published var totalCapacity: Int64 = 0

    private static let pathSpecs: [DiskMapPathSpec] = [
        DiskMapPathSpec(name: "Applications", rawPath: "/Applications", colorKey: "blue"),
        DiskMapPathSpec(name: "Library", rawPath: "~/Library", colorKey: "purple"),
        DiskMapPathSpec(name: "Documents", rawPath: "~/Documents", colorKey: "orange"),
        DiskMapPathSpec(name: "Downloads", rawPath: "~/Downloads", colorKey: "green"),
        DiskMapPathSpec(name: "Desktop", rawPath: "~/Desktop", colorKey: "pink"),
    ]

    func load() async {
        let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        let total = (attributes?[.systemSize] as? Int64) ?? 0
        let free = (attributes?[.systemFreeSize] as? Int64) ?? 0
        totalCapacity = total
        totalUsed = max(0, total - free)

        let measured = await Task.detached(priority: .userInitiated) {
            Self.pathSpecs.map { spec in
                let expanded = (spec.rawPath as NSString).expandingTildeInPath
                let size = FileManager.default.directorySize(at: URL(fileURLWithPath: expanded))
                return MeasuredDiskMapPath(name: spec.name, size: size, colorKey: spec.colorKey)
            }
        }.value

        items = measured
        .filter { $0.size > 0 }
        .map { measured in
            DiskMapItem(name: measured.name, size: measured.size, color: color(for: measured.colorKey))
        }
        .sorted { $0.size > $1.size }
    }

    private func color(for key: String) -> Color {
        switch key {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "green": return .green
        case "pink": return .pink
        default: return .gray
        }
    }
}
