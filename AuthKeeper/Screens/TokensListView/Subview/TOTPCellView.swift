//
//  TOTPCellView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 15/12/2024.
//

import Factory
import Models
import SwiftUI

struct TOTPCellView: View {
    @State private var viewModel: TOTPCellViewModel
    @Binding private var timeRemaining: TimeInterval

    init(item: TokenData, timeInterval: Binding<TimeInterval>) {
        _viewModel = .init(wrappedValue: TOTPCellViewModel(item: item))
        _timeRemaining = timeInterval
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(viewModel.item.token.issuer) - \(viewModel.item.token.name)")
                    .font(.headline)

                Text(viewModel.code)
                    .font(.largeTitle)
                    .bold()
            }
            Spacer()
            CircularProgressView(progress: viewModel.progress,
                                 countdown: Int(viewModel.remainingTime),
                                 size: 30,
                                 lineWidth: 2)
        }
        .onChange(of: timeRemaining) {
            viewModel.updateTOTP()
        }
    }
}

@MainActor
@Observable
final class TOTPCellViewModel {
    var code: String = ""
    var remainingTime: TimeInterval = 0
    var progress: Double = 1.0
    var countdown: Int = 0 // Delayed countdown
    let item: TokenData

    init(item: TokenData) {
        self.item = item

        code = item.totp ?? ""
        updateTOTP()
    }

    func updateTOTP() {
        if item.type == .totp {
            let remaining = item.remainingTime
            remainingTime = remaining > 0 ? remaining : 30
            if remainingTime >= 29 {
                // Code has expired, generate a new one
                code = item.totp ?? "Error"
            }
            progress = remainingTime / 30
            // Delayed countdown logic
            countdown = Int(remainingTime)
        } else if item.totp != code {
            // HOTP
            code = item.totp ?? "Error"
            print("woot new code id: \(item.id), code: \(code)")
        }
    }
}
