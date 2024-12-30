//
//
//  TokensListViewModel.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 15/12/2024.
//
//

import Combine
import DataLayer
import Factory
import Foundation
import Models
#if os(macOS)
import AppKit
#endif
import SwiftUI
import UIKit

@Observable @MainActor
final class TokensListViewModel: Sendable {
    var timeRemaining: TimeInterval = 0
    var searchText = ""

    @ObservationIgnored
    private var timer: MainActorIsolatedTimer?
    @ObservationIgnored
    @LazyInjected(\ServiceContainer.tokensDataService) private var tokensDataService

    private var favorites = [TokenData]()
    private var otherTokens = [TokenData]()

    private var cancellables = Set<AnyCancellable>()

    init() {
        setUp()
    }

    var filteredTokens: [TokenSection] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            return otherTokens return tokensDataService.tokens
            return tokensDataService.tokenSections
        }
        let cleanSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return tokensDataService.tokenSections.map { section in
            let token = section.tokens.filter { token in
                //            guard searchScope == .all || conversation.isFavorite else {
                //                return false
                //            }
                token.token.issuer.localizedCaseInsensitiveContains(cleanSearchText)
                    || token.token.name.localizedCaseInsensitiveContains(cleanSearchText)
                    || (token.name?.localizedCaseInsensitiveContains(cleanSearchText) ?? false)
            }
            return TokenSection(id: section.id, title: section.title, tokens: token)
        }
    }

//
//    var filteredFavorites: [TokenData] {
//        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            return favorites
//        }
//        let cleanSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//        return favorites.filter { token in
    ////            guard searchScope == .all || conversation.isFavorite else {
    ////                return false
    ////            }
//            token.token.issuer.localizedCaseInsensitiveContains(cleanSearchText)
//                || token.token.name.localizedCaseInsensitiveContains(cleanSearchText)
//                || (token.name?.localizedCaseInsensitiveContains(cleanSearchText) ?? false)
//        }
//    }

//    func getTokens() -> [TokenData] {
//        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            return tokensDataService.tokens
//        }
//        let cleanSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//        return tokensDataService.tokens.filter { token in
    ////            guard searchScope == .all || conversation.isFavorite else {
    ////                return false
    ////            }
//            token.token.issuer.localizedCaseInsensitiveContains(cleanSearchText)
//                || token.token.name.localizedCaseInsensitiveContains(cleanSearchText)
//                || (token.name?.localizedCaseInsensitiveContains(cleanSearchText) ?? false)
//        }
//    }

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

    func copyToClipboard(code: String?) {
//        guard let code else { return }
//        let pasteboard = UIPasteboard.general
//        pasteboard.string = code
    }
}

private extension TokensListViewModel {
    func setUp() {
//       $tokensDataService.tokens
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] tokens in
//                guard let self else { return }
//                Task {
//                    await filterToken(tokens: tokens.)
//                }
//            }
//            .store(in: &cancellables)
    }

    // TODO: fitler token in folder favorites and
    nonisolated func filterToken(tokens: [TokenData]) async {
//        let tokens = await tokensDataService.tokens
        var favorites = [TokenData]()
        var others = [TokenData]()
        for token in tokens {
            if token.isFavorite {
                favorites.append(token)
            } else {
                others.append(token)
            }
        }

        await MainActor.run {
            self.favorites = favorites
            self.otherTokens = others
        }
    }

    func getTokens(tokens: [TokenData]) -> [TokenData] {
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
}

enum TokensListType: Equatable, Hashable {
    case general
    case favorites
    case folder(String)

    var title: String {
        switch self {
        case .general: "General Tokens"
        case .favorites: "Favorites"
        case let .folder(title): title
        }
    }
}

struct TokensList: Identifiable, Equatable, Hashable {
    let type: TokensListType
    var tokens: [TokenData]

    var id: String { type.title }
}

extension String {
    func copy() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(self, forType: .string)
        #else
        UIPasteboard.general.string = self
        #endif
    }
}
