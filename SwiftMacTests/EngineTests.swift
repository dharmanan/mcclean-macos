import Testing
@testable import SwiftMac

@Suite("Engine Tests")
struct EngineTests {
    @Test("Clean engine handles empty input")
    func cleanEmptyInput() async {
        let result = await CleanEngine.shared.clean(items: []) { _, _ in }
        #expect(result.cleaned == 0)
        #expect(result.failed == 0)
        #expect(result.bytesFreed == 0)
    }
}
