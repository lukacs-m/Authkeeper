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
        VStack(spacing: 15) {
            if let item = viewModel.item {
                let name = item.name ?? item.token.issuer
                ZStack(alignment: .topTrailing) {
                    HStack(spacing: 0) {
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
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.9)
                            .lineLimit(1)
                            .layoutPriority(1)
                        Spacer(minLength: 5)
                        HStack {
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
//                        .layoutPriority(1)
                    }
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(.yellow)
                            .offset(x: 10, y: -10)
                    }

//                    HStack {
//                        Spacer()
//                        if item.isFavorite {
//                            Image(systemName: "star.fill")
//                                .resizable()
//                                .frame(width: 20, height: 20)
//                                .foregroundStyle(.yellow)
//                        }
//
//                        if viewModel.appConfigurationService.hideTokens {
//                            Button { viewModel.toggleTokenDisplay() } label: {
//                                Image(systemName: viewModel.showToken ? "eye.slash" : "eye")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 20, height: 20)
//                                    .foregroundStyle(.main)
//                            }
//                        }
//                    }.layoutPriority(1)
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
//            guard update else {
//                return
//            }
            viewModel.updateTOTP()
        }
//        .onChange(of: viewModel.update) {
        ////            guard update else {
        ////                return
        ////            }
//            viewModel.updateTOTP()
//        }
        .onScrollVisibilityChange(threshold: 0.2) { visible in
            //            print("\(viewModel.item?.name ?? "") is \(visible ? "visible" : "hidden")")

            viewModel.update = visible
            if visible {
                viewModel.updateTOTP()
            }
            //            if visible {
            //                viewModel.visibleCellsId.append(token.id)
            //            } else {
            //                viewModel.visibleCellsId.removeAll(where: { $0 == token.id })
            //            }
        }

//        .onAppear {
        ////            print(viewModel.item?.name ?? "")
//            viewModel.update = true
        ////            viewModel.startTimer()
//        }
//        .onDisappear {
        ////            print(viewModel.item?.name ?? "", "---")
        ////            viewModel.stopTimer()
//            viewModel.update = false
//        }
    }
}

import Combine

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
    var update = false
    private var cancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    @ObservationIgnored
    @LazyInjected(\ServiceContainer.appConfigurationService) private(set) var appConfigurationService

    @ObservationIgnored
    @LazyInjected(\ServiceContainer.timerService) private(set) var timerService

    var displayTokenState: Bool {
        (showToken && appConfigurationService.hideTokens) || !appConfigurationService.hideTokens
    }

//    init(item: TokenData) {
//        self.item = item
//
//        code = item.totp ?? ""
//        updateTOTP()
//    }
    init() {
        cancellable = timerService.timer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, update else { return }
                updateTOTP()
            }
//            .store(in: &cancellables)
    }

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

//    func startTimer() {
//        cancellable = timerService.timer
//            .subscribe(on: DispatchQueue.main)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                guard let self else { return }
//                print("should be updating ui of \(item?.name)")
//                updateTOTP()
//            }
//    }
//
//    func stopTimer() {
//        cancellable?.cancel()
//        cancellable = nil
//    }
}
