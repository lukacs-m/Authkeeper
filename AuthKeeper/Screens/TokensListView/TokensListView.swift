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
            ForEach(viewModel.getTokens(), id: \.self) { token in
                row(token: token)
                    .neumorphic()
                    .listRowBackground(Color.background)
                    .listRowSeparator(.hidden)
                    .swipeActions {
                        Button {
                            viewModel.toggleFavorite(token: token)
                        } label: {
                            Label("Favorite", systemImage: token.isFavorite ? "star.slash" : "star")
                                .contrastedText
                        }
                        .tint(.blue)

                        Button {
                            router.presentedSheet = .createEditToken(token)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .contrastedText
                        }
                        .tint(.yellow)

                        Button {
                            viewModel.delete(token: token)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                                .contrastedText
                        }
                        .tint(.error)
                    }
                    .contextMenu {
                        Button {
                            router.presentedSheet = .createEditToken(token)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .baseRoundedText
                        }
                    }
            }
            //                .onDelete(perform: deleteEntries)
        }
        .listStyle(.plain)
        .listRowSpacing(15)
        .scrollContentBackground(.hidden)
        .background(Color.background.edgesIgnoringSafeArea(.all))
        .animation(.default, value: viewModel.getTokens())
        .animation(.default, value: viewModel.searchText)
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
