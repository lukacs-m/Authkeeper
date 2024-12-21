//
//
//  AppearanceView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 21/12/2024.
//
//

import DataLayer
import SwiftUI

struct AppearanceView: View {
    @State private var viewModel = AppearanceViewModel()
    @State private var appConfiguration = ServiceContainer.shared.appConfigurationService()

    var body: some View {
        Form {
            Section {
                VStack(spacing: 10) {
                    Text("Select Color Scheme")
                        .font(.headline)

                    Picker("Color Scheme", selection: $viewModel.appConfigurationService.colorScheme) {
                        Text("System").tag(ColorSchemeOption.system)
                        Text("Light").tag(ColorSchemeOption.light)
                        Text("Dark").tag(ColorSchemeOption.dark)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

//                TextField("Name of Item", text: $viewModel.name)
//                    .font(.system(.body, design: .rounded))
//                    .foregroundStyle(.primaryText)
//                TextField("Service name *", text: $viewModel.issuer)
//                    .font(.system(.body, design: .rounded))
//                    .foregroundStyle(.primaryText)
//                TextField("Account *", text: $viewModel.account)
//                    .font(.system(.body, design: .rounded))
//                    .foregroundStyle(.primaryText)
//                SecureField("Secret key *", text: $viewModel.secret)
//                    .font(.system(.body, design: .rounded))
//                    .foregroundStyle(.primaryText)
            } header: {
                Text("Application Style")
            }

            Section {
                Toggle("Show next token", isOn: $viewModel.appConfigurationService.showNextTokens)
                    .baseRoundedText
                    .tint(.main)
                Toggle("Hide tokens", isOn: $viewModel.appConfigurationService.hideTokens)
                    .baseRoundedText
                    .tint(.main)
            } header: {
                Text("Token display")
            }
//
//            Toggle("Advance options", isOn: $showAdvanceOptions)
//                .tint(.main)

//            if showAdvanceOptions {
//                Section {
//                    TextField("Infos", text: $viewModel.complementaryInformation, axis: .vertical)
//                } header: {
//                    Text("Additional infos")
//                }
//
//                Section {
//                    Picker("Type", selection: $viewModel.type) {
//                        ForEach(OTPType.allCases) { tokenType in
//                            Text(tokenType.rawValue.capitalized)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//
//                    switch viewModel.type {
//                    case .totp:
//                        Picker("Algorithm", selection: $viewModel.algo) {
//                            ForEach(Generator.Algorithm.allCases) { algo in
//                                Text(algo.id)
//                                    .tag(algo)
//                            }
//                        }
//                        Stepper("Refresh time: **\(Int(viewModel.period))s**", value: $viewModel.period,
//                                step: 10)
//                        Stepper("Number of digits: **\(viewModel.digits)**", value: $viewModel.digits,
//                                in: 5...9)
//                    case .hotp:
//                        HStack {
//                            Text("Counter:")
//                            TextField("Initial counter", text: $viewModel.counter)
//                            #if os(iOS)
//                                .keyboardType(.decimalPad)
//                            #endif
//                        }
//                        Stepper("Number of digits: \(viewModel.digits)", value: $viewModel.digits, in: 5...8)
//                    }
//                } header: {
//                    Text("Advanced token settings")
//                }
//            }
        }
        .navigationTitle("Appearance")
        .background(Color.background)
        .toolbarBackground(Color.background,
                           for: .navigationBar)
        .preferredColorScheme(appConfiguration.colorScheme.preferredColorScheme)
    }
}

#Preview {
    AppearanceView()
}
