//
//
//  TokenFormView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 14/12/2024.
//
//

import Models
import OneTimePassword
import SwiftUI

struct TokenFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TokenFormViewModel
    @State private var showAdvanceOptions: Bool = false

    init(item: TokenData? = nil) {
        _viewModel = .init(wrappedValue: TokenFormViewModel(item: item))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name of Item", text: $viewModel.name)
                    TextField("Service name *", text: $viewModel.issuer)
                    TextField("Account", text: $viewModel.account)
                    SecureField("Secret key *", text: $viewModel.secret)
                } header: {
                    Text("Base information")
                }

                Section {
                    Toggle("Favorites", isOn: $viewModel.includeInFavorite)
                    Toggle("Widgets", isOn: $viewModel.includeInWidget)
                } header: {
                    Text("Include in: ")
                }

                Toggle("Advance options", isOn: $showAdvanceOptions)

                if showAdvanceOptions {
                    Section {
                        TextField("Infos", text: $viewModel.complementaryInformation)
                    } header: {
                        Text("Additional infos")
                    }

                    Section {
                        Picker("Type", selection: $viewModel.type) {
                            ForEach(OTPType.allCases) { tokenType in
                                Text(tokenType.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)

                        switch viewModel.type {
                        case .totp:
                            Picker("Algorithm", selection: $viewModel.algo) {
                                ForEach(Generator.Algorithm.allCases) { algo in
                                    Text(algo.id)
                                        .tag(algo)
                                }
                            }
                            Stepper("Refresh time: \(Int(viewModel.period))s", value: $viewModel.period, step: 10)
                            Stepper("Number of digits: \(viewModel.digits)", value: $viewModel.digits, in: 5...8)
                        case .hotp:
                            HStack {
                                Text("Counter:")
                                TextField("Initial counter", text: $viewModel.counter)
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                #endif
                            }
                            Stepper("Number of digits: \(viewModel.digits)", value: $viewModel.digits, in: 5...8)
                        }
                    } header: {
                        Text("Advanced token settings")
                    }
                }
            }
            .navigationTitle("Manual TOTP entry")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .opacity(viewModel.canSave ? 1 : 0)
                }
                #endif
            }
            .animation(.default, value: showAdvanceOptions)
            .animation(.default, value: viewModel.canSave)
        }
    }
}

#Preview {
    TokenFormView()
}
