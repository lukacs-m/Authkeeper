//
//
//  SettingsView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 21/12/2024.
//
//

import Factory
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appConfiguration = ServiceContainer.shared.appConfigurationService()

    @State private var viewModel = SettingsViewModel()
    @State private var router = RoutersContainer.shared.router()

    var body: some View {
        NavigationStack(path: $router.path) {
            List {
                Section {
                    Button {} label: {
                        SettingRowView(title: "Application Security", systemImage: "lock.square")
                    }
                } header: {
                    Text("Security")
                }

                Section {
                    Button { router.navigate(to: .appereance) } label: {
                        SettingRowView(title: "Appearance", systemImage: "eye.square")
                    }
                } header: {
                    Text("Preferences")
                }

                Section {
                    Button {} label: {
                        Label("Application Security", systemImage: "shield")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.primaryText)
                    }
                } header: {
                    Text("Backup & Device Synchronization")
                }

                Section {
                    Button {} label: {
                        Label("Application Security", systemImage: "shield")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.primaryText)
                    }
                } header: {
                    Text("Token management")
                }
            }
            .routingProvided
            .preferredColorScheme(appConfiguration.colorScheme.preferredColorScheme)
            .navigationTitle("Settings")
            .background(Color.background)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(Color.main)
                    }
                }
                #endif
            }
            #if os(iOS)

            .toolbarBackground(Color.background,
                               for: .navigationBar)
            #endif
        }
        .accentColor(Color.main)
        .preferredColorScheme(appConfiguration.colorScheme.preferredColorScheme)
    }
}

#Preview {
    SettingsView()
}

private struct SettingRowView: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack {
            Label {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primaryText)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(Color.main)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.main)
        }
    }
}
