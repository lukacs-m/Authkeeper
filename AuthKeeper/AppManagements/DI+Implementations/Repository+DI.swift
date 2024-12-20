//
//  Repository+DI.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 18/12/2024.
//

import DataLayer
import Factory

final class RepositoryContainer: SharedContainer, AutoRegistering, Sendable {
    static let shared = RepositoryContainer()
    let manager = ContainerManager()

    func autoRegister() {
        manager.defaultScope = .singleton
    }
}

extension RepositoryContainer {
    var tokenRepository: Factory<any TokenServicing> {
        self { TokenRepository(persistantStorage: ToolsContainer.shared.persistenceService()) }
    }
}
