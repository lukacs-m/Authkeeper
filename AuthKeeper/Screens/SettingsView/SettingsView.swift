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
            .toolbarBackground(Color.background,
                               for: .navigationBar)
        }
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

// Label {
//               Text("Here is some text, I just want to display the bubble image in Orange. Please help :) .")
//                   .font(.system(size: 16, weight: .light, design: .rounded))
//                   .multilineTextAlignment(.center)
//           } icon: {
//               Image(systemName: "questionmark.bubble")
//                   .foregroundColor(.orange)
//           }

struct ColorSchemeSelectorView: View {
    @Environment(\.colorScheme) var systemColorScheme
    @AppStorage("selectedColorScheme") private var selectedColorScheme: String = "system"

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Color Scheme")
                .font(.headline)

            Picker("Color Scheme", selection: $selectedColorScheme) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(SegmentedPickerStyle())

            Spacer()
        }
        .padding()
        .preferredColorScheme(selectedColorScheme == "system" ? nil : selectedColorScheme == "light" ? .light :
            .dark)
    }
}

//            Form {
//                Section {
//                    TextField("Name of Item", text: $viewModel.name)
//                        .font(.system(.body, design: .rounded))
//                        .foregroundStyle(.primaryText)
//                    TextField("Service name *", text: $viewModel.issuer)
//                        .font(.system(.body, design: .rounded))
//                        .foregroundStyle(.primaryText)
//                    TextField("Account *", text: $viewModel.account)
//                        .font(.system(.body, design: .rounded))
//                        .foregroundStyle(.primaryText)
//                    SecureField("Secret key *", text: $viewModel.secret)
//                        .font(.system(.body, design: .rounded))
//                        .foregroundStyle(.primaryText)
//                } header: {
//                    Text("Base information")
//                }
//
//                Section {
//                    Toggle("Favorites", isOn: $viewModel.includeInFavorite)
//                        .baseRoundedText
//                        .tint(.main)
//                    Toggle("Widgets", isOn: $viewModel.includeInWidget)
//                        .baseRoundedText
//                        .tint(.main)
//                } header: {
//                    Text("Include in: ")
//                }
//
//                Toggle("Advance options", isOn: $showAdvanceOptions)
//                    .tint(.main)
//
//                if showAdvanceOptions {
//                    Section {
//                        TextField("Infos", text: $viewModel.complementaryInformation, axis: .vertical)
//                    } header: {
//                        Text("Additional infos")
//                    }
//
//                    Section {
//                        Picker("Type", selection: $viewModel.type) {
//                            ForEach(OTPType.allCases) { tokenType in
//                                Text(tokenType.rawValue.capitalized)
//                            }
//                        }
//                        .pickerStyle(.segmented)
//
//                        switch viewModel.type {
//                        case .totp:
//                            Picker("Algorithm", selection: $viewModel.algo) {
//                                ForEach(Generator.Algorithm.allCases) { algo in
//                                    Text(algo.id)
//                                        .tag(algo)
//                                }
//                            }
//                            Stepper("Refresh time: **\(Int(viewModel.period))s**", value: $viewModel.period,
//                                    step: 10)
//                            Stepper("Number of digits: **\(viewModel.digits)**", value: $viewModel.digits,
//                                    in: 5...9)
//                        case .hotp:
//                            HStack {
//                                Text("Counter:")
//                                TextField("Initial counter", text: $viewModel.counter)
//                                #if os(iOS)
//                                    .keyboardType(.decimalPad)
//                                #endif
//                            }
//                            Stepper("Number of digits: \(viewModel.digits)", value: $viewModel.digits, in: 5...8)
//                        }
//                    } header: {
//                        Text("Advanced token settings")
//                    }
//                }
//            }
