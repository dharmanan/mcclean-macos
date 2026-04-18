import Foundation
import UserNotifications

@MainActor
final class SchedulerService: ObservableObject {
    static let shared = SchedulerService()

    enum CleaningInterval: String, CaseIterable {
        case hourly = "Hourly", daily = "Daily", weekly = "Weekly", monthly = "Monthly"
        var seconds: TimeInterval {
            switch self {
            case .hourly: return 3600; case .daily: return 86400
            case .weekly: return 604800; case .monthly: return 2592000
            }
        }
    }

    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "schedulerEnabled"); isEnabled ? setup() : cancel() }
    }
    @Published var interval: CleaningInterval {
        didSet { UserDefaults.standard.set(interval.rawValue, forKey: "schedulerInterval"); if isEnabled { setup() } }
    }

    private var timer: Timer?

    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "schedulerEnabled")
        let saved = UserDefaults.standard.string(forKey: "schedulerInterval") ?? ""
        self.interval = CleaningInterval(rawValue: saved) ?? .daily
    }

    func setupIfNeeded() async { guard isEnabled else { return }; setup() }

    private func setup() {
        cancel()
        timer = Timer.scheduledTimer(withTimeInterval: interval.seconds, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.run()
            }
        }
    }
    private func cancel() { timer?.invalidate(); timer = nil }

    private func run() async {
        let results = try? await ScanEngine.shared.scanAll { _, _ in }
        let items = results?.flatMap { $0.items }.filter { $0.isSelected } ?? []
        let (_, _, freed) = await CleanEngine.shared.clean(items: items) { _, _ in }
        let content = UNMutableNotificationContent()
        content.title = "SwiftMac — Auto Clean"
        content.body = "\(ByteCountFormatter.string(fromByteCount: freed, countStyle: .file)) freed"
        content.sound = .default
        try? await UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}
