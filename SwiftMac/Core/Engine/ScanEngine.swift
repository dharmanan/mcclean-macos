import Foundation

protocol ScannerProtocol: Sendable {
    func scan() async throws -> [FileItem]
}

actor ScanEngine {
    static let shared = ScanEngine()
    private var isCancelled = false

    func cancel() { isCancelled = true }

    func scanAll(
        progress: @escaping @MainActor @Sendable (CategoryType, ScanCategory) -> Void
    ) async throws -> [ScanCategory] {
        isCancelled = false

        return try await withThrowingTaskGroup(of: ScanCategory.self) { group in
            let scanners: [(CategoryType, any ScannerProtocol)] = [
                (.systemJunk,      SystemJunkScanner()),
                (.userCache,       UserCacheScanner()),
                (.mailAttachments, MailAttachmentScanner()),
                (.trash,           TrashScanner()),
                (.largeFiles,      LargeFileScanner()),
                (.purgeable,       PurgeableScanner()),
                (.xcodeJunk,       XcodeScanner()),
                (.homebrewCache,   HomebrewScanner()),
            ]

            for (type, scanner) in scanners {
                group.addTask {
                    let items = try await scanner.scan()
                    let totalSize = items.reduce(0) { $0 + $1.size }
                    let category = ScanCategory(type: type, items: items, totalSize: totalSize)
                    await progress(type, category)
                    return category
                }
            }

            var results: [ScanCategory] = []
            for try await cat in group { results.append(cat) }
            return results.sorted { $0.totalSize > $1.totalSize }
        }
    }
}
