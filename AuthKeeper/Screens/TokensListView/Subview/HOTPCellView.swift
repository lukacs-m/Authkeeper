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
        HStack {
            if let item = viewModel.item {
                VStack(alignment: .leading) {
                    Text("\(item.token.issuer) - \(item.token.name)")
                        .font(.headline)

                    Text(item.totp ?? "")
                        .font(.largeTitle)
                        .bold()
                }
            }
            Spacer()
            Button {
                viewModel.updateHotpToken()
            } label: {
                Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .symbolEffect(.rotate.counterClockwise.wholeSymbol,
                          options: .speed(3).nonRepeating,
                          value: viewModel.animate)
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
