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

    func addToken(token: TokenData) async
    func delete(token: TokenData) async
    func update(token: TokenData) async
    func token(for tokenId: String) -> TokenData?
}

@MainActor
@Observable
public final class TokensDataService: TokensDataServicing {
    public private(set) var tokens: [TokenData] = []

    public nonisolated init() {
        Task {
            await setUp()
        }
    }

    func setUp() {
        prefileData()
    }

    func prefileData() {
        guard let secretData = Base32Codec.data(from: "aaaa"),
              !secretData.isEmpty,
              let generator = try? Generator(factor: .timer(period: 30),
                                             secret: secretData,
                                             algorithm: .sha1,
                                             digits: 6) else {
            print("Invalid secret")
            return
        }
        let token = Token(generator: generator, name: "hello", issuer: "issue")
        let tokenData = TokenData(name: "woot", token: token)

        guard let secretData2 = Base32Codec.data(from: "bbbb"),
              !secretData2.isEmpty,
              let generator2 = try? Generator(factor: .timer(period: 30),
                                              secret: secretData2,
                                              algorithm: .sha1,
                                              digits: 6) else {
            print("Invalid secret")
            return
        }
        let token2 = Token(generator: generator2, name: "Plop", issuer: "ploo")
        let tokenData2 = TokenData(name: "woot", token: token2)

        guard let secretData3 = Base32Codec.data(from: "bbbb"),
              !secretData3.isEmpty,
              let generator3 = try? Generator(factor: .counter(0),
                                              secret: secretData3,
                                              algorithm: .sha1,
                                              digits: 6) else {
            print("Invalid secret")
            return
        }
        let token3 = Token(generator: generator3, name: "Plop", issuer: "ploo")
        let tokenData3 = TokenData(name: "counter", token: token3)
        Task { @MainActor in
            tokens.append(tokenData)
            tokens.append(tokenData2)
            tokens.append(tokenData3)
        }
    }
}

// MARK: - Protocol conformance

public extension TokensDataService {
    func addToken(token: TokenData) async {
        tokens.append(token)
    }

    func delete(token: TokenData) async {
        tokens.removeAll { $0.id == token.id }
    }

    func update(token: TokenData) async {
        if let index = tokens.firstIndex(where: { $0.id == token.id }) {
            tokens[index] = token
        }
    }

    func token(for tokenId: String) -> TokenData? {
        tokens.first(where: { $0.id == tokenId })
    }
}
