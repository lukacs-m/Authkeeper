//
//  Services+DI.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 14/12/2024.
//

import DataLayer
import Factory

final class ServiceContainer: SharedContainer, AutoRegistering, Sendable {
    static let shared = ServiceContainer()
    let manager = ContainerManager()

    func autoRegister() {
        manager.defaultScope = .singleton
    }
}

extension ServiceContainer {
    var tokensDataService: Factory<any TokensDataServicing> {
        self { TokensDataService() }
    }
}
