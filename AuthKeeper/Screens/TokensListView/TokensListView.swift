//
//
//  TokensListView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 15/12/2024.
//
//

import Models
import SwiftUI

struct TokensListView: View {
    @State private var viewModel = TokensListViewModel()
    @Environment(Router.self) private var router

    var body: some View {
        List {
            ForEach(viewModel.getTokens()) { token in
                VStack(alignment: .leading) {
                    row(token: token)
                        .swipeActions {
                            Button {
                                viewModel.toggleFavorite(token: token)
                            } label: {
                                Label("Favorite", systemImage: token.isFavorite ? "star.slash" : "star")
                            }
                            .tint(.blue)

                            Button {
                                router.presentedSheet = .createEditToken(token)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.yellow)

                            Button {
                                viewModel.delete(token: token)
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            .tint(.red)
                        }
                        .contextMenu {
                            Button {
                                router.presentedSheet = .createEditToken(token)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                }
            }
//                .onDelete(perform: deleteEntries)
        }
        .animation(.default, value: viewModel.getTokens())
        .onAppear {
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .navigationTitle("AuthKeeper")
        #if os(iOS)
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search")
        #endif
    }

    @ViewBuilder
    func row(token: TokenData) -> some View {
        if token.type == .totp {
            TOTPCellView(item: token, timeInterval: $viewModel.timeRemaining)
        } else {
            HOTPCellView(itemId: token.id)
        }
    }
}

#Preview {
    TokensListView()
}
