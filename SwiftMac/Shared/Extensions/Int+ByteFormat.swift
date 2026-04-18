import Foundation

extension Int64 {
    var byteString: String { ByteCountFormatter.string(fromByteCount: self, countStyle: .file) }
}
extension Int {
    var byteString: String { ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file) }
}
