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

    @State private var visibleCells: [TokenData] = []
    var body: some View {
        //        List {
        //            ForEach(viewModel.filteredTokens) { section in
        //                favoriteListSection(tokenSection: section)
        //            }
        ////            otherTokenSection
        //            //                .onDelete(perform: deleteEntries)
        //        }
        //        .listStyle(.plain)
        //        #if os(iOS)
        //            .listRowSpacing(15)
        //        #endif

        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.filteredTokens) { section in
                    favoriteListSection(tokenSection: section)
                }
            }
            .scrollTargetLayout()
        }
        .onScrollTargetVisibilityChange(idType: TokenData.self) { elements in
            visibleCells = elements
        }
        .scrollContentBackground(.hidden)
        .background(Color.background.edgesIgnoringSafeArea(.all))
        .animation(.default, value: viewModel.filteredTokens)
        .animation(.default, value: viewModel.searchText)
        .animation(.default, value: viewModel.sectionsDisplayState)
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
            TOTPCellView(item: token,
                         timeInterval: visibleCells.contains { $0.id == token.id } ? $viewModel
                             .timeRemaining : .constant(viewModel.timeRemaining))
        } else {
            HOTPCellView(itemId: token.id)
        }
    }

    func favoriteListSection(tokenSection: TokenSection) -> some View {
        Section {
            //            if let state = viewModel.sectionsDisplayState[tokenSection.id],
            //               !state {
            //                EmptyView()
            //            } else {
            if viewModel.displayingSection(for: tokenSection.id) {
                ForEach(tokenSection.tokens, id: \.self) { token in
                    row(token: token)
                        .onTapGesture {
                            viewModel.copyToClipboard(code: token.totp)
                        }
                        .neumorphic()
                        .listRowBackground(Color.background)
                        .listRowSeparator(.hidden)
                        //                        .swipeActions {
                        //                            Button {
                        //                                viewModel.toggleFavorite(token: token)
                        //                            } label: {
                        //                                Label("Favorite", systemImage: token.isFavorite ?
                        //                                "star.slash" : "star")
                        //                                    .contrastedText
                        //                            }
                        //                            .tint(.blue)
                        //
                        //                            Button {
                        //                                router.presentedSheet = .createEditToken(token)
                        //                            } label: {
                        //                                Label("Edit", systemImage: "pencil")
                        //                                    .contrastedText
                        //                            }
                        //                            .tint(.yellow)
                        //
                        //                            Button {
                        //                                viewModel.delete(token: token)
                        //                            } label: {
                        //                                Label("Delete", systemImage: "trash.fill")
                        //                                    .contrastedText
                        //                            }
                        //                            .tint(.error)
                        //                        }
                        .contextMenu {
                            //                            Button {
                            //                                router.presentedSheet = .createEditToken(token)
                            //                            } label: {
                            //                                Label("Edit", systemImage: "pencil")
                            //                                    .baseRoundedText
                            //                            }
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
                }
                .padding(.horizontal)
            }
        } header: {
            HStack {
                Text("\(tokenSection.title) (\(tokenSection.itemCount))")
                    .bold()
                Spacer()
                Button { viewModel.toggleSectionDisplay(for: tokenSection.id) } label: {
                    Image(systemName: viewModel
                        .displayingSection(for: tokenSection.id) ? "chevron.up" : "chevron.down")
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
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
