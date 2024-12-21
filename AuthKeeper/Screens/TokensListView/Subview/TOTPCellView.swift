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
        VStack {
            ZStack(alignment: .trailing) {
                if let title = viewModel.item.name {
                    Text(title)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                if viewModel.item.isFavorite {
                    Image(systemName: "start")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.yellow)
                        .padding(.trailing, 10)
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("\(viewModel.item.token.issuer)")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if !viewModel.item.token.name.isEmpty {
                        Text("\(viewModel.item.token.name)")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity)
                ZStack {
                    HStack {
                        Divider()
                            .overlay(Color.primaryText)
                    }
                    CircularProgressView(progress: viewModel.progress,
                                         countdown: Int(viewModel.remainingTime),
                                         size: 35,
                                         lineWidth: 2)
                        .padding(.vertical, 3)
                        .background(Color.background)
                }
                Text(viewModel.code)
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundStyle(.primaryText)
            }
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
