//
//
//  TokensListView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 15/12/2024.
//
//

import DataLayer
import Models
import SwiftUI

struct TokensListView: View {
    @State private var viewModel = TokensListViewModel()
    @Environment(Router.self) private var router

    var body: some View {
        List {
            ForEach(viewModel.filteredTokens) { section in
                favoriteListSection(tokenSection: section)
            }
//            otherTokenSection
            //                .onDelete(perform: deleteEntries)
        }
        .listStyle(.plain)
        #if os(iOS)
            .listRowSpacing(15)
        #endif
            .scrollContentBackground(.hidden)
            .background(Color.background.edgesIgnoringSafeArea(.all))
//            .animation(.default, value: viewModel.getTokens())
            .animation(.default, value: viewModel.filteredTokens)
//            .animation(.default, value: viewModel.filteredFavorites)
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

    func favoriteListSection(tokenSection: TokenSection) -> some View {
        Section {
            ForEach(tokenSection.tokens, id: \.self) { token in
                row(token: token)
                    .onTapGesture {
                        viewModel.copyToClipboard(code: token.totp)
                    }
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
        } header: {
            HStack {
                Text("\(tokenSection.title) (\(tokenSection.itemCount))")
                Spacer()
            }
        }
    }

//    var otherTokenSection: some View {
//        Section {
//            ForEach(viewModel.filteredTokens, id: \.self) { token in
//                row(token: token)
//                    .onTapGesture {
//                        viewModel.copyToClipboard(code: token.totp)
//                    }
//                    .neumorphic()
//                    .listRowBackground(Color.background)
//                    .listRowSeparator(.hidden)
//                    .swipeActions {
//                        Button {
//                            viewModel.toggleFavorite(token: token)
//                        } label: {
//                            Label("Favorite", systemImage: token.isFavorite ? "star.slash" : "star")
//                                .contrastedText
//                        }
//                        .tint(.blue)
//
//                        Button {
//                            router.presentedSheet = .createEditToken(token)
//                        } label: {
//                            Label("Edit", systemImage: "pencil")
//                                .contrastedText
//                        }
//                        .tint(.yellow)
//
//                        Button {
//                            viewModel.delete(token: token)
//                        } label: {
//                            Label("Delete", systemImage: "trash.fill")
//                                .contrastedText
//                        }
//                        .tint(.error)
//                    }
//                    .contextMenu {
//                        Button {
//                            router.presentedSheet = .createEditToken(token)
//                        } label: {
//                            Label("Edit", systemImage: "pencil")
//                                .baseRoundedText
//                        }
//                    }
//            }
//        } header: {
//            Text("Other Tokens")
//        }
//    }
}

#Preview {
    TokensListView()
}
