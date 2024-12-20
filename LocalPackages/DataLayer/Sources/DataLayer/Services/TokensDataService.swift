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
}

@MainActor
@Observable
public final class TokensDataService: TokensDataServicing {
    public private(set) var tokens: [TokenData] = []

    private let tokenRepository: any TokenServicing

    public init(tokenRepository: any TokenServicing) {
        self.tokenRepository = tokenRepository
        setUp()
    }

    func setUp() {
        Task {
            if let localTokens = try? await tokenRepository.getAllTokens() {
                tokens = localTokens
            }
        }
//        prefileData()
    }

//    func prefileData() {
//        guard let secretData = Base32Codec.data(from: "aaaa"),
//              !secretData.isEmpty,
//              let generator = try? Generator(factor: .timer(period: 30),
//                                             secret: secretData,
//                                             algorithm: .sha1,
//                                             digits: 6) else {
//            print("Invalid secret")
//            return
//        }
//        let token = Token(generator: generator, name: "hello", issuer: "issue")
//        let tokenData = TokenData(name: "woot", token: token)
//
//        guard let secretData2 = Base32Codec.data(from: "bbbb"),
//              !secretData2.isEmpty,
//              let generator2 = try? Generator(factor: .timer(period: 30),
//                                              secret: secretData2,
//                                              algorithm: .sha1,
//                                              digits: 6) else {
//            print("Invalid secret")
//            return
//        }
//        let token2 = Token(generator: generator2, name: "Plop", issuer: "ploo")
//        let tokenData2 = TokenData(name: "woot", token: token2)
//
//        guard let secretData3 = Base32Codec.data(from: "bbbb"),
//              !secretData3.isEmpty,
//              let generator3 = try? Generator(factor: .counter(0),
//                                              secret: secretData3,
//                                              algorithm: .sha1,
//                                              digits: 6) else {
//            print("Invalid secret")
//            return
//        }
//        let token3 = Token(generator: generator3, name: "Plop", issuer: "ploo")
//        let tokenData3 = TokenData(name: "counter", token: token3)
//        Task { @MainActor in
//            tokens.append(tokenData)
//            tokens.append(tokenData2)
//            tokens.append(tokenData3)
//        }
//    }
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
}
