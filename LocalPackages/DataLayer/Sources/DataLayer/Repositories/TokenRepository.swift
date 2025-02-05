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
    func save(_ tokens: [TokenData]) async throws -> [TokenData]

    func remove(_ token: TokenData) async throws
    func removeAll() async throws
}

public final class TokenRepository: TokenServicing {
    private let persistentStorage: any PersistenceServicing
    private let encryptionService: any EncryptionServicing
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    public let tokens: CurrentValueSubject<[TokenData], Never> = .init([])

    public init(persistentStorage: any PersistenceServicing,
                encryptionService: any EncryptionServicing) {
        self.persistentStorage = persistentStorage
        self.encryptionService = encryptionService
    }
}

public extension TokenRepository {
    func getAllTokens() async throws -> [TokenData] {
        let encryptedTokens: [TokenDataEntity] = try await persistentStorage.fetchAll()
        return encryptedTokens.compactMap { encryptedEntity in
            guard let decryptedData: Data = try? encryptionService.decrypt(encryptedEntity.encryptedData) else {
                return nil
            }
            return try? decoder.decode(TokenData.self, from: decryptedData)
        }
    }

    func save(_ token: TokenData) async throws {
        let entity = try createEntity(token)
        try await persistentStorage.save(data: entity)
        try await update()
    }

    func save(_ tokens: [TokenData]) async throws -> [TokenData] {
        let entities: [TokenDataEntity] = tokens.compactMap {
            guard let entity = try? createEntity($0) else {
                return nil
            }
            return entity
        }

        try await persistentStorage.batchSave(content: entities)
        return try await update()
    }

    func remove(_ token: TokenData) async throws {
        let id = token.id
        let predicate = #Predicate<TokenDataEntity> { entity in
            entity.id == id
        }
        guard let entity: TokenDataEntity = try await persistentStorage.fetchOne(predicate: predicate) else {
            return
        }
        try await persistentStorage.delete(element: entity)
        try await update()
    }

    func removeAll() async throws {
        try await persistentStorage.deleteAll(dataTypes: [TokenDataEntity.self])
        try await update()
    }
}

private extension TokenRepository {
    @discardableResult
    func update() async throws -> [TokenData] {
        let bars: [TokenData] = try await getAllTokens() // persistentStorage.fetchAll().toTokens
        tokens.send(bars)
        return bars
    }

    func createEntity(_ token: TokenData) throws -> TokenDataEntity {
        let data = try encoder.encode(token)
        guard let encryptedData: Data = try encryptionService.encrypt(data) else {
            throw TokenRepositoryError.failedToEncrypt
        }
        return TokenDataEntity(id: token.id, encryptedData: encryptedData)
    }
}

enum TokenRepositoryError: Error {
    case failedToDecrypt
    case failedToEncrypt
}
