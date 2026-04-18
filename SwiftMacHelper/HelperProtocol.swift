import Foundation

@objc protocol HelperProtocol {
    func removeItem(atPath path: String, withReply reply: @escaping (Bool) -> Void)
}
