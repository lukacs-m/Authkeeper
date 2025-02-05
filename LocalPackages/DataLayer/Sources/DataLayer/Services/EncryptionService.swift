//
//  EncryptionService.swift
//  DataLayer
//
//  Created by martin on 23/01/2025.
//

import CryptoKit
import Foundation
@preconcurrency import KeychainAccess

public protocol EncryptionServicing: Sendable {
    func encrypt(_ data: Data) throws -> Data?
    func decrypt(_ data: Data) throws -> Data?
}

public final class EncryptionService: EncryptionServicing {
    private let keychain: Keychain
    private let key = "encryptionKey"

    public init(keychain: Keychain = Keychain(service: AppConstants.service,
                                              accessGroup: AppConstants.keychainGroup)
            .synchronizable(true)) {
        self.keychain = keychain
        if keychain[data: key] == nil {
            let symmetricKey = SymmetricKey(size: .bits256)
            let keyData = symmetricKey.withUnsafeBytes { Data($0) }
            keychain[data: key] = keyData
        }
    }

    private var encryptionKey: SymmetricKey? {
        get throws {
            guard let data = try keychain.getData(key) else {
                return nil
            }
            return SymmetricKey(data: data)
        }
    }

    public func encrypt(_ data: Data) throws -> Data? {
        guard let encryptionKey = try encryptionKey else {
            return nil
        }
        let sealedBox = try ChaChaPoly.seal(data, using: encryptionKey)
        return sealedBox.combined
    }

    public func decrypt(_ data: Data) throws -> Data? {
        guard let encryptionKey = try encryptionKey else {
            return nil
        }
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        return try ChaChaPoly.open(sealedBox, using: encryptionKey)
    }
}
