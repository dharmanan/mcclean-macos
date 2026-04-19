import Foundation

protocol ScannerProtocol: Sendable {
    func scan() async throws -> [FileItem]
}

actor ScanEngine {
    static let shared = ScanEngine()
    private var isCancelled = false

    static var scannerCount: Int { configuredScanners().count }

    private static func configuredScanners() -> [(CategoryType, any ScannerProtocol)] {
        [
            (.systemJunk,      SystemJunkScanner()),
            (.userCache,       UserCacheScanner()),
            (.mailAttachments, MailAttachmentScanner()),
            (.trash,           TrashScanner()),
            (.largeFiles,      LargeFileScanner()),
            (.purgeable,       PurgeableScanner()),
            (.xcodeJunk,       XcodeScanner()),
            (.homebrewCache,   HomebrewScanner()),
        ]
    }

    func cancel() { isCancelled = true }

    private func shouldCancel() -> Bool { isCancelled }

    func scanAll(
        progress: @escaping @MainActor @Sendable (CategoryType, ScanCategory) -> Void
    ) async throws -> [ScanCategory] {
        isCancelled = false
        let scanners = Self.configuredScanners()

        return try await withThrowingTaskGroup(of: ScanCategory.self) { group in
            for (type, scanner) in scanners {
                group.addTask { [weak self] in
                    try Task.checkCancellation()
                    if let self, await self.shouldCancel() { throw CancellationError() }

                    let items = try await scanner.scan()
                    try Task.checkCancellation()
                    if let self, await self.shouldCancel() { throw CancellationError() }

                    let totalSize = items.reduce(0) { $0 + $1.size }
                    let category = ScanCategory(type: type, items: items, totalSize: totalSize)
                    await progress(type, category)
                    return category
                }
            }

            var results: [ScanCategory] = []
            for try await cat in group {
                if isCancelled {
                    group.cancelAll()
                    throw CancellationError()
                }
                results.append(cat)
            }
            return results.sorted { $0.totalSize > $1.totalSize }
        }
    }
}
