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
final class RootViewModel {
    init() {
        setUp()
    }
}

private extension RootViewModel {
    func setUp() {
        print("woot \(Bundle.main.infoDictionary!["AppIdentifierPrefix"] as? String)")
    }
}

@globalActor
actor ManagerActor {
    static let shared = ManagerActor()

    private init() {}
}
