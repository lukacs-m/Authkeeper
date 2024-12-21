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
                if let title = item.name {
                    Text(title)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
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
                                .overlay(Color.secondaryText)
                        }
                        Button {
                            viewModel.updateHotpToken()
                        } label: {
                            Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundStyle(Color.main)
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .symbolEffect(.rotate.counterClockwise.wholeSymbol,
                                      options: .speed(3).nonRepeating,
                                      value: viewModel.animate)
                        .padding(.vertical, 3)
                        .background(Color.background)
                    }
                    Text(item.totp ?? "")
                        .font(.system(.title, design: .rounded))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle(.primaryText)
                }
            }
        }
    }
}

@MainActor
@Observable
final class HOTPCellViewModel {
    private(set) var animate = false

    private let itemId: String
    @ObservationIgnored
    @LazyInjected(\ServiceContainer.tokensDataService) private var tokensDataService

    var item: TokenData? {
        tokensDataService.token(for: itemId)
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
}
