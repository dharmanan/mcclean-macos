import Foundation

struct TrashScanner: ScannerProtocol {
    let trashDirectory: URL

    init(trashDirectory: URL? = nil) {
        self.trashDirectory = trashDirectory ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")
    }

    func scan() async throws -> [FileItem] {
        guard let contents = try? FileManager.default.contentsOfDirectory(at: trashDirectory, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) else { return [] }
        return contents.map { url in
            let v = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            return FileItem(url: url, size: Int64(v?.fileSize ?? 0), modifiedDate: v?.contentModificationDate)
        }
    }
}
