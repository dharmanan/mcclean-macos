import Foundation

final class HelperImplementation: NSObject, HelperProtocol {
    func removeItem(atPath path: String, withReply reply: @escaping (Bool) -> Void) {
        do {
            try FileManager.default.removeItem(atPath: path)
            reply(true)
        } catch {
            reply(false)
        }
    }
}
