import Foundation

struct UserCacheScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dirs = [
            home.appendingPathComponent("Library/Caches"),
            home.appendingPathComponent(".npm"), home.appendingPathComponent(".yarn/cache"),
            home.appendingPathComponent(".pip/cache"), home.appendingPathComponent(".cache"),
            home.appendingPathComponent("Library/Application Support/Google/Chrome/Default/Cache"),
            home.appendingPathComponent("Library/Caches/com.apple.Safari"),
        ]
        var items: [FileItem] = []
        for dir in dirs { items += (try? scanDir(dir)) ?? [] }
        return items
    }

    private func scanDir(_ url: URL) throws -> [FileItem] {
        guard let e = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey]) else { return [] }
        var items: [FileItem] = []
        for case let f as URL in e {
            let v = try f.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey])
            guard v.isRegularFile == true else { continue }
            items.append(FileItem(url: f, size: Int64(v.fileSize ?? 0), modifiedDate: v.contentModificationDate))
        }
        return items
    }
}
