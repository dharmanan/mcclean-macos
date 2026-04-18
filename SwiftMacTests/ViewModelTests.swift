import Testing
@testable import SwiftMac

@Suite("ViewModel Tests")
struct ViewModelTests {
    @Test("Dashboard view model starts idle")
    @MainActor
    func dashboardInitialState() {
        let viewModel = DashboardViewModel()
        #expect(viewModel.categories.isEmpty)
        #expect(viewModel.totalFound == 0)
        #expect(viewModel.totalCleaned == 0)
    }
}
