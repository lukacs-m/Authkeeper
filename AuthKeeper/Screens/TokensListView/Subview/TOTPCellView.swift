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
    @State private var viewModel = TOTPCellViewModel()
    @Binding private var timeRemaining: TimeInterval
    @Namespace private var totpAnimation
    @Namespace private var totpCode

    init(item: TokenData, timeInterval: Binding<TimeInterval>) {
//        _viewModel = .init(wrappedValue: TOTPCellViewModel(item: item))
        _timeRemaining = timeInterval
        viewModel.update(item: item)
    }

    var body: some View {
        VStack {
            if let item = viewModel.item {
                let name = item.name ?? item.token.issuer
                ZStack {
                    HStack {
                        Spacer()
//                        #if os(iOS)
//
//                        if let image = UIImage(named: item.token.issuer) {
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30, height: 30)
//                        }
//                        #endif
                        Text(name)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        if item.isFavorite {
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.yellow)
                        }

                        if viewModel.appConfigurationService.hideTokens {
                            Button { viewModel.toggleTokenDisplay() } label: {
                                Image(systemName: viewModel.showToken ? "eye.slash" : "eye")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.main)
                            }
                        }
                    }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Text("\(item.token.issuer)")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if !item.token.name.isEmpty {
                            Text("\(item.token.name)")
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

                    VStack {
                        Text(viewModel.displayTokenState ? viewModel.code : String(repeating: "●",
                                                                                   count: viewModel.code.count))
                            .font(.system(viewModel.displayTokenState ? .largeTitle : .title3, design: .rounded)
                                .bold())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)

                        Text(viewModel.displayTokenState ? item
                            .nextTotp ?? "" : String(repeating: "●", count: viewModel.item?.nextTotp?.count ?? 0))
                            .font(.system(.caption, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle(.secondaryText)
                            .opacity(viewModel.appConfigurationService.showNextTokens && viewModel
                                .countdown < 15 ? 1 : 0)
                    }
                    .animation(.default, value: viewModel.code)
                }
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
    private(set) var item: TokenData?
    private(set) var showToken = false

    @ObservationIgnored
    @LazyInjected(\ServiceContainer.appConfigurationService) private(set) var appConfigurationService

    var displayTokenState: Bool {
        (showToken && appConfigurationService.hideTokens) || !appConfigurationService.hideTokens
    }

//    init(item: TokenData) {
//        self.item = item
//
//        code = item.totp ?? ""
//        updateTOTP()
//    }
    init() {}

    func update(item: TokenData) {
        self.item = item

        code = item.totp ?? ""
        updateTOTP()
    }

    func updateTOTP() {
        guard let item else { return }
        if item.type == .totp {
            let remaining = item.remainingTime
            remainingTime = remaining > 0 ? remaining : item.periode
            if remainingTime >= item.periode - 1 {
                // Code has expired, generate a new one
                code = item.totp ?? "Error"
            }
            progress = remainingTime / item.periode
            // Delayed countdown logic
            countdown = Int(remainingTime)
        } else if item.totp != code {
            // HOTP
            code = item.totp ?? "Error"
            print("woot new code id: \(item.id), code: \(code)")
        }
    }

    func toggleTokenDisplay() {
        showToken.toggle()
    }
}
