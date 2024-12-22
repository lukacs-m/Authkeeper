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

    func addToken(token: TokenData) async throws
    func delete(token: TokenData) async throws
    func update(token: TokenData) async throws
    func token(for tokenId: String) -> TokenData?

    func generateAndAddToken(from payload: String) async throws
}

@MainActor
@Observable
public final class TokensDataService: TokensDataServicing {
    public private(set) var tokens: [TokenData] = []

    private let tokenRepository: any TokenServicing

    private var task: Task<Void, Never>?
    public init(tokenRepository: any TokenServicing) {
        self.tokenRepository = tokenRepository
        setUp()
    }

    func setUp() {
        guard task == nil else { return }
        task = Task {
            if let localTokens = try? await tokenRepository.getAllTokens() {
                tokens = localTokens
            }
        }
    }
}

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
}
