//
//  TokensDataService.swift
//  DataLayer
//
//  Created by Martin Lukacs on 14/12/2024.
//
import Models
import OneTimePassword
import SwiftUI

@MainActor
public protocol TokensDataServicing: Sendable, Observable {
    var tokens: [TokenData] { get }
    var tokenSections: [TokenSection] { get }

    func addToken(token: TokenData) async throws
    func delete(token: TokenData) async throws
    func update(token: TokenData) async throws
    func token(for tokenId: String) -> TokenData?
    func addOrUpdate(tokens: [TokenData]) async throws

    func generateAndAddToken(from payload: String) async throws
}

//
// public struct TokenSection: Identifiable {
//    public let id: String
//    public let title: String
//    public let tokens: [TokenData]
// }

// @MainActor
// @Observable
// public final class TokensDataService: TokensDataServicing {
//    public private(set) var tokens: [TokenData] = []
//    private let tokenRepository: any TokenServicing
//    private var task: Task<Void, Never>?
//
//    public init(tokenRepository: any TokenServicing) {
//        self.tokenRepository = tokenRepository
//        setUp()
//    }
//
//    func setUp() {
//        guard task == nil else { return }
//        task = Task {
//            if let localTokens = try? await tokenRepository.getAllTokens() {
//                tokens = localTokens
//            }
//        }
//    }
// }

// MARK: - Protocol conformance

public extension TokensDataService {
    func addToken(token: TokenData) async throws {
        try await tokenRepository.save(token)
        tokens.append(token)
    }

    func delete(token: TokenData) async throws {
        try await tokenRepository.remove(token)
        tokens.removeAll { $0.id == token.id }
    }

    func update(token: TokenData) async throws {
        try await tokenRepository.save(token)
        if let index = tokens.firstIndex(where: { $0.id == token.id }) {
            tokens[index] = token
        }
    }

    func token(for tokenId: String) -> TokenData? {
        tokens.first(where: { $0.id == tokenId })
    }

    func generateAndAddToken(from payload: String) async throws {
        guard let tokenURL = URL(string: payload) else { return }
        let token = try Token(url: tokenURL)
        let tokenData = TokenData(token: token)
        try await addToken(token: tokenData)
    }

    func addOrUpdate(tokens: [TokenData]) async throws {
        self.tokens = try await tokenRepository.save(tokens)
    }
}

public struct TokenSection: Identifiable, Sendable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let isFavorites: Bool
    public let tags: Set<String>
    public let tokens: [TokenData]

    public init(id: String, title: String, isFavorites: Bool, tags: Set<String>, tokens: [TokenData]) {
        self.id = id
        self.title = title
        self.isFavorites = isFavorites
        self.tokens = tokens
        self.tags = tags
    }

    public var itemCount: Int { tokens.count }
}

public enum SortOrder: Sendable {
    case ascending
    case descending
}

@MainActor
@Observable
public final class TokensDataService: TokensDataServicing {
    // MARK: - Properties

    public private(set) var tokens: [TokenData] = [] {
        didSet {
            // Move rebuildSections off the main thread if it might be expensive
            scheduleRebuildSections()
        }
    }

    public private(set) var tokenSections: [TokenSection] = []

    public var sortOrder: SortOrder = .ascending {
        didSet {
            scheduleRebuildSections()
        }
    }

    private let tokenRepository: any TokenServicing
    private var task: Task<Void, Never>?

    // MARK: - Init

    public init(tokenRepository: any TokenServicing) {
        self.tokenRepository = tokenRepository
        setUp()
    }

    private func setUp() {
        guard task == nil else { return }
        task = Task {
//            try? await seedTestTokens()
            if let localTokens = try? await tokenRepository.getAllTokens() {
                tokens = localTokens
            }
        }
    }

    // MARK: - Scheduling Rebuild

    /// If the token list is large, we might not want to rebuild synchronously on every change.
    /// For example, you can implement a throttle or simply dispatch to a detached task.
    private func scheduleRebuildSections() {
        Task { @MainActor in
            let newSections = await buildSections()
            // Hop back to the MainActor to apply the changes
            tokenSections = newSections
        }
    }

    // MARK: - Building Sections in Background

    /// Build the sections array in a background-friendly method.
    /// This method should be non-isolated from the main actor so it can run off the main thread.
    private nonisolated func buildSections() async -> [TokenSection] {
        // Capture a snapshot of data we need
        let currentTokens = await tokens
        let currentSortOrder = await sortOrder

        // Single-pass grouping: favorites vs folder mapping
        let (favorites, folderMapping) = currentTokens.reduce(into: ([TokenData](),
                                                                     [String: [
                                                                         TokenData
                                                                     ]]())) { partialResult, token in
            if token.isFavorite {
                partialResult.0.append(token) // favorites array
            } else {
                let folderId = token.folderId ?? "no_folder"
                partialResult.1[folderId, default: []].append(token)
            }
        }

        // Sort favorites once
        let sortedFavorites = sortTokensByName(favorites, order: currentSortOrder)

        // Sort folder IDs
        let folderIds = folderMapping.keys.sorted { lhs, rhs in
            switch currentSortOrder {
            case .ascending: lhs < rhs
            case .descending: lhs > rhs
            }
        }

        // Create new sections
        var sections: [TokenSection] = []

        // If there are favorites, add them as the first section
        if !sortedFavorites.isEmpty {
            sections.append(TokenSection(id: "favorites",
                                         title: "Favorites",
                                         isFavorites: true,
                                         tags: sortedFavorites.getTags,
                                         tokens: sortedFavorites))
        }

        // Add sections for each folder
        for folderId in folderIds {
            if let tokensInFolder = folderMapping[folderId] {
                let sortedFolderTokens = sortTokensByName(tokensInFolder, order: currentSortOrder)
                let displayTitle = (folderId == "no_folder") ? "Unassigned" : folderId
                sections.append(TokenSection(id: folderId,
                                             title: displayTitle,
                                             isFavorites: false,
                                             tags: sortedFolderTokens.getTags,
                                             tokens: sortedFolderTokens))
            }
        }

        return sections
    }

    private nonisolated func sortTokensByName(_ tokens: [TokenData], order: SortOrder) -> [TokenData] {
        tokens.sorted {
            switch order {
            case .ascending:
                ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending
            case .descending:
                ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == .orderedDescending
            }
        }
    }

//    // MARK: - Protocol conformance
//
//    public func addToken(token: TokenData) async throws {
//        try await tokenRepository.save(token)
//        tokens.append(token)
//    }
//
//    public func delete(token: TokenData) async throws {
//        try await tokenRepository.remove(token)
//        tokens.removeAll { $0.id == token.id }
//    }
//
//    public func update(token: TokenData) async throws {
//        try await tokenRepository.save(token)
//        if let index = tokens.firstIndex(where: { $0.id == token.id }) {
//            tokens[index] = token
//        }
//    }
//
//    public func token(for tokenId: String) -> TokenData? {
//        tokens.first(where: { $0.id == tokenId })
//    }
//
//    public func generateAndAddToken(from payload: String) async throws {
//        guard let tokenURL = URL(string: payload) else { return }
//        let token = try Token(url: tokenURL)
//        let tokenData = TokenData(token: token)
//        try await addToken(token: tokenData)
//    }
}

public extension TokensDataService {
    /// Seeds the database with 3000 test tokens, each having random issuer and account name.
    func seedTestTokens() async throws {
        // Example: a fake shared secret for TOTP
        let secretData = Data("FAKESECRETSEED".utf8)

        // Some sample data to randomize
        let possibleIssuers = ["Google", "Microsoft", "GitHub", "Amazon", "Facebook", "Slack"]
        let possibleBaseNames = ["john", "jane", "alex", "chris", "maria", "user123"]
        let possibleFolders: [String?] = ["Finance", "Social", "Work", "Personal", nil]

        var newTokens: [TokenData] = []
        for i in 1...1_000 {
            // Randomly pick an issuer
            let issuer = possibleIssuers.randomElement() ?? ""

            // Randomly pick a base account name and build a string like "alex123@example.com"
            let baseName = possibleBaseNames.randomElement() ?? ""
            let accountName = "\(baseName)\(i)@example.com"

            // TOTP generator (adjust to your OTP library)
            let generator = try Generator(factor: .timer(period: 30),
                                          secret: secretData,
                                          algorithm: .sha1,
                                          digits: 6)

            // Create the Token; your actual Token init might differ
            // (e.g., some libraries let you specify name/issuer directly).
            let token = Token(generator: generator, name: baseName, issuer: issuer)
            // If your Token type has `name` or `issuer` properties, set them here.
            // For demonstration, we’re just showing potential usage:
            // token.name = accountName
            // token.issuer = issuer

            // Randomly pick from a small set of folder IDs
            let randomFolder = possibleFolders.randomElement()!

            // Maybe 1 in 8 tokens is a favorite
            let isFavorite = (Int.random(in: 1...8) == 1)

            // Build a TokenData struct
            let tokenData = TokenData(name: accountName,
                                      iconUrl: nil,
                                      token: token,
                                      folderId: randomFolder,
                                      isFavorite: isFavorite,
                                      widgetActivated: false,
                                      complementaryInfos: "Issuer: \(issuer)")

            // Save it to the repo and append to our local array
            newTokens.append(tokenData)
        }

        try await addOrUpdate(tokens: newTokens) // addToken(token: tokenData)
    }
}

private extension [TokenData] {
    var getTags: Set<String> {
        Set(self.compactMap((\.tags)).flatMap(\.self))
    }
}
