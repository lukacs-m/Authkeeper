// The Swift Programming Language
// https://docs.swift.org/swift-book

import CryptoKit
import Foundation
import OneTimePassword

//
// public struct TOTPEntry: Identifiable, Codable {
//    public let id: String
//    public let issuer: String
//    public let account: String
//    public let secret: String
//    public let period: TimeInterval
//    public let digits: Int
//    public var name: String?
//
//    init(id: String = UUID().uuidString, issuer: String, account: String, secret: String, period: TimeInterval, digits: Int, name: String? = nil) {
//        self.id = id
//        self.issuer = issuer
//        self.account = account
//        self.secret = secret
//        self.period = period
//        self.digits = digits
//        self.name = name
//    }
//
//    public  func generateTOTP() -> String? {
//        let timeCounter = UInt64(Date().timeIntervalSince1970 / period)
//        guard let key = Data(base64Encoded: secret) else { return nil }
//
//        var counter = timeCounter.bigEndian
//        let counterData = withUnsafeBytes(of: &counter) { Data($0) }
//
//        let hmac = HMAC<SHA1>.authenticationCode(for: counterData, using: SymmetricKey(data: key))
//        let offset = hmac.last! & 0x0F
//        let truncatedHash = hmac[offset...offset+3]
//        let code = truncatedHash.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian & 0x7FFFFFFF }
//        let otp = code % UInt32(pow(10.0, Double(digits)))
//
//        return String(format: "%0\(digits)d", otp)
//    }
//
//    public  func remainingTime() -> TimeInterval {
//        period - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: period)
//    }
// }

extension Token: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(issuer)
        hasher.combine(generator)
    }
}

extension Generator: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(factor)
        hasher.combine(secret)
        hasher.combine(algorithm)
        hasher.combine(digits)
    }
}

extension Generator.Factor: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .counter(value):
            hasher
                .combine(value) // combine with associated value, if it's not `Hashable` map it to some `Hashable`
        // type and then combine result
        case let .timer(value):
            hasher
                .combine(value) // combine with associated value, if it's not `Hashable` map it to some `Hashable`
            // type and then combine result
        }
    }
}

public struct TokenData: Identifiable, Sendable, Hashable {
    public let id: String
    public let name: String?
    public let iconUrl: String?
    public let token: Token
    public let isFavorite: Bool
    public let widgetActivated: Bool
    public let complementaryInfos: String?

    public init(id: String = UUID().uuidString,
                name: String? = nil,
                iconUrl: String? = nil,
                token: Token,
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

public enum OTPType: String, CaseIterable, Codable, Identifiable {
    case totp
    case hotp

    public var id: Self { self }
}
