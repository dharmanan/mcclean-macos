import Foundation
import CryptoKit

struct DuplicateScanner: ScannerProtocol {
    let searchDirectories: [URL]

    init(searchDirectories: [URL]? = nil) {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.searchDirectories = searchDirectories ?? ["Downloads", "Documents", "Desktop", "Pictures"].map {
            home.appendingPathComponent($0)
        }
    }

    func scan() async throws -> [FileItem] {
        var all: [FileItem] = []
        for dir in searchDirectories { all += gatherFiles(in: dir) }
        return findDuplicates(in: all)
    }

    private func gatherFiles(in dir: URL) -> [FileItem] {
        guard let e = FileManager.default.enumerator(at: dir, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey]) else { return [] }
        var items: [FileItem] = []
        for case let url as URL in e {
            let v = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey])
            guard v?.isRegularFile == true, let sz = v?.fileSize, sz > 0 else { continue }
            items.append(FileItem(url: url, size: Int64(sz), modifiedDate: v?.contentModificationDate))
        }
        return items
    }

    private func findDuplicates(in files: [FileItem]) -> [FileItem] {
        let bySize = Dictionary(grouping: files) { $0.size }
        let candidates = bySize.filter { $0.value.count > 1 }.flatMap { $0.value }
        var hashMap: [String: [FileItem]] = [:]
        for file in candidates {
            guard let hash = sha256(of: file.url) else { continue }
            hashMap[hash, default: []].append(file)
        }
        var duplicates: [FileItem] = []
        for (_, group) in hashMap where group.count > 1 {
            let sorted = group.sorted { ($0.modifiedDate ?? .distantPast) < ($1.modifiedDate ?? .distantPast) }
            duplicates += sorted.dropFirst()
        }
        return duplicates
    }

    private func sha256(of url: URL) -> String? {
        let bufferSize = 64 * 1024
        guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { handle.closeFile() }

        var hasher = SHA256()
        while true {
            let data = handle.readData(ofLength: bufferSize)
            if data.isEmpty { break }
            hasher.update(data: data)
        }

        return hasher.finalize().compactMap { String(format: "%02x", $0) }.joined()
    }
}
