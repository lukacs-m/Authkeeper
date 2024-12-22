//
//
//  ScannerView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 21/12/2024.
//
//

import DocScanner
import SwiftUI

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = ScannerViewModel()

    var body: some View {
        DataScanner(with: .barcode,
                    startScanning: $viewModel.scanning,
//                    shouldDismiss:  Binding(
//                        get: { !viewModel.showScanner },
//                        set: { viewModel.showScanner = !$0 }
//                    ),
                    automaticDismiss: true
//                    regionOfInterest: $viewModel.regionOfInterest,
        ) { results in
            viewModel.processPayload(results: results)
            dismiss()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ScannerView()
}
