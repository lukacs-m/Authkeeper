// The Swift Programming Language
// https://docs.swift.org/swift-book

import CryptoKit
import Foundation
import ModifiedCopy
import OneTimePassword

public enum OTPType: String, CaseIterable, Codable, Identifiable {
    case totp
    case hotp

    public var id: Self { self }
}

// @Copyable
public struct TokenData: Identifiable, Sendable, Hashable, Equatable {
    public let id: String
    public let name: String?
    public let iconUrl: String?
    public let token: Token
    public let folderId: String?
    public let isFavorite: Bool
    public let widgetActivated: Bool
    public let complementaryInfos: String?
    public let tags: [String]?
    private let precomputedHash: Int

    public init(id: String = UUID().uuidString,
                name: String? = nil,
                iconUrl: String? = nil,
                token: Token,
                folderId: String? = nil,
                isFavorite: Bool = false,
                widgetActivated: Bool = false,
                complementaryInfos: String? = nil,
                tags: [String]? = nil) {
        self.id = id
        self.name = name
        self.iconUrl = iconUrl
        self.token = token
        self.isFavorite = isFavorite
        self.widgetActivated = widgetActivated
        self.complementaryInfos = complementaryInfos
        self.folderId = folderId
        self.tags = tags
        precomputedHash = Self.computeHash(id: id,
                                           name: name,
                                           iconUrl: iconUrl,
                                           folderId: folderId,
                                           isFavorite: isFavorite,
                                           widgetActivated: widgetActivated,
                                           tags: tags,
                                           complementaryInfos: complementaryInfos)
    }

    public var remainingTime: TimeInterval {
        guard let period = token.generator.factor.period else { return 0 }
        return period - Date().timeIntervalSince1970.truncatingRemainder(dividingBy: period)
    }

    public var totp: String? {
        token.currentPassword
    }

    public var nextTotp: String? {
        let periode = token.generator.factor.period ?? 0
        return try? token.generator.password(at: .now + periode)
    }

    public var type: OTPType {
        if case .timer = token.generator.factor {
            .totp
        } else {
            .hotp
        }
    }

    public var periode: TimeInterval {
        guard let period = token.generator.factor.period else { return 0 }
        return period
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

    /// Returns a copy of the caller whose value for `isFavorite` is different.
    public func copy(isFavorite: Bool) -> Self {
        .init(id: id,
              name: name,
              iconUrl: iconUrl,
              token: token,
              folderId: folderId,
              isFavorite: isFavorite,
              widgetActivated: widgetActivated,
              complementaryInfos: complementaryInfos,
              tags: tags)
    }
}

// MARK: - Hashable

extension TokenData {
    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(precomputedHash)
    }

    // MARK: - Static Helper for Hash Precomputation

    private static func computeHash(id: String,
                                    name: String?,
                                    iconUrl: String?,
                                    folderId: String?,
                                    isFavorite: Bool,
                                    widgetActivated: Bool,
                                    tags: [String]?,
                                    complementaryInfos: String?) -> Int {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(iconUrl)
        hasher.combine(folderId)
        hasher.combine(isFavorite)
        hasher.combine(widgetActivated)
        hasher.combine(tags)
        hasher.combine(complementaryInfos)
        return hasher.finalize()
    }
}
