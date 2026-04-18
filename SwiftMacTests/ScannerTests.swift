import Testing
@testable import SwiftMac

@Suite("Scanner Tests")
struct ScannerTests {
    @Test("System junk scanner returns valid items")
    func systemJunk() async throws {
        let items = try await SystemJunkScanner().scan()
        for item in items {
            #expect(!item.url.path.isEmpty)
            #expect(item.size >= 0)
        }
    }

    @Test("Large file scanner respects threshold")
    func largeFileThreshold() async throws {
        let scanner = LargeFileScanner()
        let items = try await scanner.scan()
        for item in items {
            #expect(item.size >= scanner.minSizeBytes)
        }
    }

    @Test("Trash scanner targets correct directory")
    func trashPath() async throws {
        let items = try await TrashScanner().scan()
        for item in items {
            #expect(item.url.path.contains(".Trash"))
        }
    }
}
