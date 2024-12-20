//
//  Tools+DI.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 18/12/2024.
//

import DataLayer
import Factory
import SimplyPersist
import SwiftData

final class ToolsContainer: SharedContainer, AutoRegistering, Sendable {
    static let shared = ToolsContainer()
    let manager = ContainerManager()

    func autoRegister() {
        manager.defaultScope = .singleton
    }
}

extension ToolsContainer {
    var persistenceService: Factory<any PersistenceServicing> {
        self {
            do {
                return try PersistenceService(with: ModelConfiguration(for: TokenDataEntity.self))
            } catch {
                fatalError("Should have persistence storage \(error)")
            }
        }
    }
}
