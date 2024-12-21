//
//  Routers+DI.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 21/12/2024.
//

import Factory
import Foundation

/// Container for Routers
final class RoutersContainer: SharedContainer {
    static let shared = RoutersContainer()
    let manager = ContainerManager()
}

extension RoutersContainer {
    var router: Factory<Router> {
        self { @MainActor in Router() }
    }
}
