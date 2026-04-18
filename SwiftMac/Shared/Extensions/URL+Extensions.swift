import Foundation

extension URL {
    var fileNameWithoutExtension: String {
        deletingPathExtension().lastPathComponent
    }

    var isHiddenFile: Bool {
        lastPathComponent.hasPrefix(".")
    }
}
