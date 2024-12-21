//
//  AuthKeeperApp.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 28/07/2024.
//

import SwiftData
import SwiftUI

@main
struct AuthKeeperApp: App {
    @State private var appConfiguration = ServiceContainer.shared.appConfigurationService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(appConfiguration.colorScheme.preferredColorScheme)
            #if os(macOS)
                .frame(minWidth: 729, minHeight: 480)
            #endif
        }
        #if os(macOS)
        .windowResizability(.contentMinSize)
        #endif
    }
}
