// The Swift Programming Language
// https://docs.swift.org/swift-book

import CryptoKit
import Foundation
import OneTimePassword

// extension Token: @retroactive Hashable {
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//        hasher.combine(name)
//        hasher.combine(issuer)
//        hasher.combine(generator)
//    }
// }
//
// extension Generator: @retroactive Hashable {
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(factor)
//        hasher.combine(secret)
//        hasher.combine(algorithm)
//        hasher.combine(digits)
//    }
// }
//
// extension Generator.Factor: @retroactive Hashable {
//    public func hash(into hasher: inout Hasher) {
//        switch self {
//        case let .counter(value):
//            hasher
//                .combine(value) // combine with associated value, if it's not `Hashable` map it to some
//                `Hashable`
//        // type and then combine result
//        case let .timer(value):
//            hasher
//                .combine(value) // combine with associated value, if it's not `Hashable` map it to some
//                `Hashable`
//            // type and then combine result
//        }
//    }
// }

public enum OTPType: String, CaseIterable, Codable, Identifiable {
    case totp
    case hotp

    public var id: Self { self }
}

public struct TokenData: Identifiable, Sendable, Hashable {
    public let id: String
    public let name: String?
    public let iconUrl: String?
    public let token: Token
    public let isFavorite: Bool
    public let widgetActivated: Bool
    public let complementaryInfos: String?
    public let folderId: String?

    public init(id: String = UUID().uuidString,
                name: String? = nil,
                iconUrl: String? = nil,
                token: Token,
                folderId: String? = nil,
                isFavorite: Bool = false,
                widgetActivated: Bool = false,
                complementaryInfos: String? = nil) {
        self.id = id
        self.name = name
        self.iconUrl = iconUrl
        self.token = token
        self.isFavorite = isFavorite
        self.widgetActivated = widgetActivated
        self.complementaryInfos = complementaryInfos
        self.folderId = folderId
    }

    public var remainingTime: TimeInterval {
        guard let period = token.generator.factor.period else { return 0 }
        return period - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: period)
    }

    public var totp: String? {
        token.currentPassword
    }

    public var type: OTPType {
        if case .timer = token.generator.factor {
            .totp
        } else {
            .hotp
        }
    }

    public func updatedToken() -> TokenData {
        let newToken = token.updatedToken()
        return TokenData(id: id,
                         name: name,
                         iconUrl: iconUrl,
                         token: newToken,
                         isFavorite: isFavorite,
                         widgetActivated: widgetActivated)
    }
}
