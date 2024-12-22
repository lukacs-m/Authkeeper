//
//  HOTPCellView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 15/12/2024.
//

import Factory
import Models
import SwiftUI

struct HOTPCellView: View {
    @State private var viewModel: HOTPCellViewModel

    init(itemId: String) {
        _viewModel = .init(wrappedValue: HOTPCellViewModel(itemId: itemId))
    }

    var body: some View {
        VStack {
            if let item = viewModel.item {
                ZStack(alignment: .trailing) {
                    Text(item.name ?? item.token.issuer)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Button {
                            viewModel.updateHotpToken()
                        } label: {
                            Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.main)
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .symbolEffect(.rotate.counterClockwise.wholeSymbol,
                                      options: .speed(3).nonRepeating,
                                      value: viewModel.animate)
                        .padding(.vertical, 3)
                        .background(Color.background)
                        Spacer()
                        if item.isFavorite {
                            Image(systemName: "star.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.yellow)
                        }

                        if viewModel.appConfigurationService.hideTokens {
                            Button { viewModel.toggleTokenDisplay() } label: {
                                Image(systemName: "eye")
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
                    HStack {
                        Divider()
                            .overlay(Color.secondaryText)
                    }

                    Text(viewModel.displayTokenState ? item.totp ?? "" : String(repeating: "●",
                                                                                count: item.totp?.count ?? 0))
                        .font(.system(viewModel.displayTokenState ? .largeTitle : .title3, design: .rounded)
                            .bold())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }
        }
    }
}

@MainActor
@Observable
final class HOTPCellViewModel {
    private(set) var animate = false
    private(set) var showToken = false

    @ObservationIgnored
    @LazyInjected(\ServiceContainer.tokensDataService) private var tokensDataService
    @ObservationIgnored
    @LazyInjected(\ServiceContainer.appConfigurationService) var appConfigurationService

    private let itemId: String

    var item: TokenData? {
        tokensDataService.token(for: itemId)
    }

    var displayTokenState: Bool {
        (showToken && appConfigurationService.hideTokens) || !appConfigurationService.hideTokens
    }

    init(itemId: String) {
        self.itemId = itemId
    }

    func updateHotpToken() {
        guard let item, item.type == .hotp else { return }
        Task {
            do {
                try await tokensDataService.update(token: item.updatedToken())
                animate.toggle()
            } catch {
                print(error)
            }
        }
    }

    func toggleTokenDisplay() {
        showToken.toggle()
    }
}
