import Foundation
import Security

final class KeychainHelper {
    static let standard = KeychainHelper(); private init() {}

    func save(_ data: Data, service: String, account: String) {
        let q:[String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemDelete(q as CFDictionary)
        SecItemAdd(q as CFDictionary, nil)
    }

    func read(service: String, account: String) -> Data? {
        let q:[String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    func delete(service: String, account: String) {
        let q:[String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(q as CFDictionary)
    }

    // helpers
    func saveString(_ value: String, service: String, account: String) {
        if let data = value.data(using: .utf8) { save(data, service: service, account: account) }
    }
    func readString(service: String, account: String) -> String? {
        guard let data = read(service: service, account: account) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
