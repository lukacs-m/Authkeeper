//
//
//  TokensListViewModel.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 15/12/2024.
//
//

import Factory
import Foundation
import Models

@Observable @MainActor
final class TokensListViewModel: Sendable {
    var timeRemaining: TimeInterval = 0
    var searchText = ""

    @ObservationIgnored
    private var timer: MainActorIsolatedTimer?
    @ObservationIgnored
    @LazyInjected(\ServiceContainer.tokensDataService) private var tokensDataService

    init() {
        setUp()
    }

    func getTokens() -> [TokenData] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return tokensDataService.tokens
        }
        let cleanSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return tokensDataService.tokens.filter { token in
//            guard searchScope == .all || conversation.isFavorite else {
//                return false
//            }
            token.token.issuer.localizedCaseInsensitiveContains(cleanSearchText)
                || token.token.name.localizedCaseInsensitiveContains(cleanSearchText)
                || (token.name?.localizedCaseInsensitiveContains(cleanSearchText) ?? false)
        }
    }

    func startTimer() {
        stopTimer()
        startMainActorIsolatedTimer()
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func startMainActorIsolatedTimer() {
        timer = MainActorIsolatedTimer(interval: 0.1,
                                       repeats: true,
                                       clockType: .continuous) { [weak self] _ in
            self?.timeRemaining = Date().timeIntervalSince1970
        }
    }

    func delete(token: TokenData) {
        Task {
            do {
                try await tokensDataService.delete(token: token)
            } catch {
                print(error)
            }
        }
    }

    func toggleFavorite(token: TokenData) {
        Task {
            do {
                let newTokensData = token.copy(isFavorite: !token.isFavorite)
                try await tokensDataService.update(token: newTokensData)
            } catch {
                print(error)
            }
        }
    }
}

private extension TokensListViewModel {
    func setUp() {}
}
