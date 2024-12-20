//
//  TokenRepository.swift
//  DataLayer
//
//  Created by Martin Lukacs on 18/12/2024.
//

@preconcurrency import Combine
import Foundation
import Models
import os
import SimplyPersist
import SwiftData

public protocol TokenServicing: Sendable {
    nonisolated var tokens: CurrentValueSubject<[TokenData], Never> { get }

    func getAllTokens() async throws -> [TokenData]
    func save(_ token: TokenData) async throws
    func remove(_ token: TokenData) async throws
    func removeAll() async throws
}

public final class TokenRepository: TokenServicing {
    private let persistantStorage: any PersistenceServicing
    public let tokens: CurrentValueSubject<[TokenData], Never> = .init([])

    public init(persistantStorage: any PersistenceServicing) {
        self.persistantStorage = persistantStorage
    }
}

public extension TokenRepository {
    func getAllTokens() async throws -> [TokenData] {
        try await persistantStorage.fetchAll().toTokens
    }

    func save(_ token: TokenData) async throws {
        try await persistantStorage.save(data: token.toEntity)
        try await update()
    }

    func remove(_ token: TokenData) async throws {
        let id = token.id
        let predicate = #Predicate<TokenDataEntity> { entity in
            entity.id == id
        }
        guard let entity: TokenDataEntity = try await persistantStorage.fetchOne(predicate: predicate) else {
            return
        }
        try await persistantStorage.delete(element: entity)
        try await update()
    }

    func removeAll() async throws {
        try await persistantStorage.deleteAll(dataTypes: [TokenDataEntity.self])
        try await update()
    }

    private func update() async throws {
        let bars: [TokenData] = try await persistantStorage.fetchAll().toTokens
        tokens.send(bars)
    }
}
