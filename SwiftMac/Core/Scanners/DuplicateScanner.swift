import Foundation
import CryptoKit

struct DuplicateScanner: ScannerProtocol {
    func scan() async throws -> [FileItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let dirs = ["Downloads","Documents","Desktop","Pictures"].map { home.appendingPathComponent($0) }
        var all: [FileItem] = []
        for dir in dirs { all += gatherFiles(in: dir) }
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
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
        return SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }
}
