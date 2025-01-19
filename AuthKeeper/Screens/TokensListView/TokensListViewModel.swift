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
    var selectedtag = "All"

    private(set) var sectionsDisplayState = [String: Bool]()
    @ObservationIgnored var searchText = "" {
        didSet {
            searchTextStream.send(searchText)
        }
    }

    @ObservationIgnored
    var visibleCellsId: [String] = []

    private var favorites = [TokenData]()
    private var otherTokens = [TokenData]()
    @ObservationIgnored
    private var timer: MainActorIsolatedTimer?
    @ObservationIgnored
    private let searchTextStream: CurrentValueSubject<String, Never> = .init("")
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    private var lastestQuery = ""

    @ObservationIgnored
    @LazyInjected(\ServiceContainer.tokensDataService) private var tokensDataService

    init() {
        setUp()
        searchTextStream
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSearch in
                guard let self else { return }
                lastestQuery = newSearch.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }
            .store(in: &cancellables)
    }

    var filteredTokens: [TokenSection] {
        let isFilteringBySearchText = !lastestQuery.isEmpty
        let isFilteringByTag = selectedtag != "All"

        // Return unfiltered data if no filters are applied
        guard isFilteringBySearchText || isFilteringByTag else {
            return tokensDataService.tokenSections
        }

        // Apply filters
        return tokensDataService.tokenSections.compactMap { section in
            let filteredTokens = section.tokens.filter { token in
                let matchesSearchText = isFilteringBySearchText &&
                    (token.token.issuer.localizedCaseInsensitiveContains(lastestQuery) ||
                        token.token.name.localizedCaseInsensitiveContains(lastestQuery) ||
                        (token.name?.localizedCaseInsensitiveContains(lastestQuery) ?? false))
                var matchesTag = false
                if isFilteringByTag, let tags = token.tags {
                    matchesTag = tags.contains(selectedtag)
                }
//                 = isFilteringByTag && token.tags.contains(selectedtag)
                return matchesSearchText || matchesTag
            }

//            // Skip sections without matching tokens
//            guard !filteredTokens.isEmpty else { return nil }

            return TokenSection(id: section.id,
                                title: section.title,
                                isFavorites: section.isFavorites,
                                tags: section.tags,
                                tokens: filteredTokens)
        }
    }

//    var filteredTokens: [TokenSection] {
//
//        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, selectedtag != "All" else {
    ////            return otherTokens return tokensDataService.tokens
//            return tokensDataService.tokenSections
//        }
//        let cleanSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//        return tokensDataService.tokenSections.map { section in
//            let token = section.tokens.filter { token in
//                //            guard searchScope == .all || conversation.isFavorite else {
//                //                return false
//                //            }
//                (token.token.issuer.localizedCaseInsensitiveContains(cleanSearchText)
//                    || token.token.name.localizedCaseInsensitiveContains(cleanSearchText)
//                    || (token.name?.localizedCaseInsensitiveContains(cleanSearchText) ?? false))
//            }
//            return TokenSection(id: section.id,
//                                title: section.title,
//                                isFavorites: section.isFavorites,
//                                tags: section.tags,
//                                tokens: token)
//        }
//    }

    func isVisible(id: String) -> Bool {
        visibleCellsId.contains(id)
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

    func toggleSectionDisplay(for sectionId: String) {
        if let currentState = sectionsDisplayState[sectionId] {
            sectionsDisplayState[sectionId] = !currentState
        } else {
            sectionsDisplayState[sectionId] = false
        }
    }

    func displayingSection(for sectionId: String) -> Bool {
        guard let currentState = sectionsDisplayState[sectionId] else {
            return true
        }
        return currentState
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

//    // TODO: fitler token in folder favorites and
//    nonisolated func filterToken(tokens: [TokenData]) async {
    ////        let tokens = await tokensDataService.tokens
//        var favorites = [TokenData]()
//        var others = [TokenData]()
//        for token in tokens {
//            if token.isFavorite {
//                favorites.append(token)
//            } else {
//                others.append(token)
//            }
//        }
//
//        await MainActor.run {
//            self.favorites = favorites
//            self.otherTokens = others
//        }
//    }
//
//    func getTokens(tokens: [TokenData]) -> [TokenData] {
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

// private extension [TokenSection] {
//    var tags: [String]? {
//        self.compactMap { guard !$0.tags.isEmpty else { return nil}
//            return $0.tags
//        }
//            .reduce(into: Set<String>()) { $0.union($1) }
//            .sorted()
//    }
// }

// extension Array where Element == TokenSection
extension [TokenSection] {
    /// Returns an optional array of strings containing unique tags from all sections.
    /// - Returns: An array of tags with "All" as the first element, or `nil` if no tags are present.
    var tags: [String]? {
        // Collect all tags from the sections
        let combinedTags = self.reduce(into: Set<String>()) { result, section in
            result.formUnion(section.tags)
        }

        // If no tags are found, return nil
        guard !combinedTags.isEmpty else { return nil }

        // Return the tags as an array with "All" as the first element
        return ["All"] + combinedTags.sorted()
    }
}
