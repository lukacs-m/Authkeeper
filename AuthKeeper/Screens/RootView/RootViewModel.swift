//
//
//  RootViewModel.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 08/12/2024.
//
//

import Factory
import Foundation
import Models
import OneTimePassword

@MainActor
@Observable
final class RootViewModel: Sendable {
    init() {
        setUp()
    }
}

private extension RootViewModel {
    func setUp() {}
}

@globalActor
actor ManagerActor {
    static let shared = ManagerActor()

    private init() {}
}
