import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let size: Int64
    let modifiedDate: Date?
    var isSelected: Bool = true

    var name: String { url.lastPathComponent }
    var path: String { url.path }
    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}
