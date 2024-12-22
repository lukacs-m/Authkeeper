//
//
//  RootView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 08/12/2024.
//
//

import Models
import SwiftUI

// protocol TimerUpdate: Sendable, Observable {
//    @MainActor
//    var update: () -> Void { get }
// }

// protocol AcquisitionStateServicing: Sendable, Observable {
//    @MainActor
//    func updateState(newState: AcquisitionState)
// }

// extension EnvironmentValues {
//    @Entry var acquisitionState: any TimerUpdate = RootViewModel()
// }

struct RootView: View {
    @State private var viewModel = RootViewModel()
    @State private var router: Router = .init()
    @State private var animated = false

    var body: some View {
        NavigationSplitView {
            TokensListView()
                .environment(router)
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            #endif
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button { router.presentedSheet = .barcodeScanner } label: {
                                Label("Scan QR", systemImage: "qrcode.viewfinder")
                            }
                            Button { router.presentedSheet = .createEditToken(nil) } label: {
                                Label("Add", systemImage: "plus")
                            }
                            Button { router.presentedSheet = .createEditToken(nil) } label: {
                                Label("Import", systemImage: "square.and.arrow.down")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(Color.main)
                        }
                    }

                    ToolbarItem(placement: .topBarLeading) {
                        Button { router.presentedSheet = .settings } label: {
                            Label("Settings", systemImage: "gear")
                                .foregroundStyle(Color.main)
                        }
                    }
                    #endif
                }
                .withSheetDestinations(sheetDestinations: $router.presentedSheet)
//                .sheet(item: $router.presentedSheet,
//                       content: { presentedSheet in
//                           switch presentedSheet {
//                           case let .createEditToken(token):
//                               TokenFormView(item: token)
//                           case .settings:
//                               SettingsView()
//                           }
//                       })
        } detail: {
            Text("Select an Totp entry")
        }
        .accentColor(.main)
    }
}

#Preview {
    RootView()
}
