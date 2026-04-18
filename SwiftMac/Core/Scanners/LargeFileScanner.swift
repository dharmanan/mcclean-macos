import Foundation

struct LargeFileScanner: ScannerProtocol {
    let minSizeBytes: Int64 = 100 * 1024 * 1024

    func scan() async throws -> [FileItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dirs = ["Downloads","Documents","Desktop","Movies"].map { home.appendingPathComponent($0) }
        var items: [FileItem] = []
        for dir in dirs {
            guard let e = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey]) else { continue }
            for case let url as URL in e {
                let v = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey])
                guard v?.isRegularFile == true, let sz = v?.fileSize, Int64(sz) >= minSizeBytes else { continue }
                items.append(FileItem(url: url, size: Int64(sz), modifiedDate: v?.contentModificationDate))
            }
        }
        return items.sorted { $0.size > $1.size }
    }
}
