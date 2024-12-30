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
        }
        .navigationTitle("Appearance")
        .background(Color.background)
        #if os(iOS)
            .toolbarBackground(Color.background, for: .navigationBar)
        #endif
            .preferredColorScheme(viewModel.appConfigurationService.colorScheme.preferredColorScheme)
    }
}

#Preview {
    AppearanceView()
}
