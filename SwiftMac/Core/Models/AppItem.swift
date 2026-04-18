import Foundation
import AppKit

struct AppItem: Identifiable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let bundleURL: URL
    let version: String
    let size: Int64
    var residualFiles: [FileItem] = []
    var isSelected: Bool = false

    var totalSize: Int64 { size + residualFiles.reduce(0) { $0 + $1.size } }
    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    var icon: NSImage? { NSWorkspace.shared.icon(forFile: bundleURL.path) }
}
