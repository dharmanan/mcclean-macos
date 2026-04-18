import Foundation

struct TrashScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let trash = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")
        guard let contents = try? FileManager.default.contentsOfDirectory(at: trash, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) else { return [] }
        return contents.map { url in
            let v = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            return FileItem(url: url, size: Int64(v?.fileSize ?? 0), modifiedDate: v?.contentModificationDate)
        }
    }
}
