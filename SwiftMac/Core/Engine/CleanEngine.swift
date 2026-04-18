import Foundation

actor CleanEngine {
    static let shared = CleanEngine()

    func clean(
        items: [FileItem],
        progress: @escaping @Sendable (FileItem, Bool) -> Void
    ) async -> (cleaned: Int, failed: Int, bytesFreed: Int64) {
        var cleaned = 0; var failed = 0; var bytesFreed: Int64 = 0
        for item in items where item.isSelected {
            do {
                try FileManager.default.removeItem(at: item.url)
                cleaned += 1; bytesFreed += item.size
                await MainActor.run { progress(item, true) }
            } catch {
                failed += 1
                await MainActor.run { progress(item, false) }
            }
        }
        return (cleaned, failed, bytesFreed)
    }

    func moveToTrash(items: [FileItem]) async -> Int64 {
        var freed: Int64 = 0
        for item in items where item.isSelected {
            try? FileManager.default.trashItem(at: item.url, resultingItemURL: nil)
            freed += item.size
        }
        return freed
    }
}
