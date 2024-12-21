//
//
//  AppearanceViewModel.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 21/12/2024.
//
//

import DataLayer
import Factory
import Foundation

@Observable @MainActor
final class AppearanceViewModel: Sendable {
    @ObservationIgnored
    @LazyInjected(\ServiceContainer.appConfigurationService) var appConfigurationService

    init() {
        setUp()
    }
}

private extension AppearanceViewModel {
    func setUp() {}
}
