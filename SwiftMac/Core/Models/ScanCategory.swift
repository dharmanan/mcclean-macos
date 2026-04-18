import Foundation

enum CategoryType: String, CaseIterable, Codable {
    case systemJunk = "System Junk"
    case userCache = "User Cache"
    case mailAttachments = "Mail Attachments"
    case trash = "Trash"
    case largeFiles = "Large Files"
    case purgeable = "Purgeable Space"
    case xcodeJunk = "Xcode Junk"
    case homebrewCache = "Homebrew Cache"
    case applications = "Applications"
    case duplicates = "Duplicates"
    case privacy = "Privacy"

    var icon: String {
        switch self {
        case .systemJunk: return "gearshape.2"
        case .userCache: return "folder.badge.gear"
        case .mailAttachments: return "paperclip"
        case .trash: return "trash"
        case .largeFiles: return "doc.badge.ellipsis"
        case .purgeable: return "externaldrive.badge.timemachine"
        case .xcodeJunk: return "hammer"
        case .homebrewCache: return "mug"
        case .applications: return "square.grid.2x2"
        case .duplicates: return "doc.on.doc"
        case .privacy: return "eye.slash"
        }
    }
}

struct ScanCategory: Identifiable, Hashable {
    let id = UUID()
    let type: CategoryType
    var items: [FileItem]
    var totalSize: Int64
    var isScanning: Bool = false

    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }

    static func == (lhs: ScanCategory, rhs: ScanCategory) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
