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

// ********
// struct TokensListView: View {
//    @State private var viewModel = TokensListViewModel()
//    @Environment(Router.self) private var router
//
//    @State private var visibleCells: [TokenData] = []
//    var body: some View {
//        //        List {
//        //            ForEach(viewModel.filteredTokens) { section in
//        //                favoriteListSection(tokenSection: section)
//        //            }
//        ////            otherTokenSection
//        //            //                .onDelete(perform: deleteEntries)
//        //        }
//        //        .listStyle(.plain)
//        //        #if os(iOS)
//        //            .listRowSpacing(15)
//        //        #endif
//
//        ScrollView {
//            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
//                ForEach(viewModel.filteredTokens) { section in
//                    favoriteListSection(tokenSection: section)
//                }
//            }
//            .scrollTargetLayout()
//        }
//        .onScrollTargetVisibilityChange(idType: TokenData.self) { elements in
//            visibleCells = elements
//        }
//        .scrollContentBackground(.hidden)
//        .background(Color.background.edgesIgnoringSafeArea(.all))
//        .animation(.default, value: viewModel.filteredTokens)
//        .animation(.default, value: viewModel.searchText)
//        .animation(.default, value: viewModel.sectionsDisplayState)
//        .onAppear {
//            viewModel.startTimer()
//        }
//        .onDisappear {
//            viewModel.stopTimer()
//        }
//        .navigationTitle("AuthKeeper")
//        #if os(iOS)
//            .searchable(text: $viewModel.searchText,
//                        placement: .navigationBarDrawer(displayMode: .always),
//                        prompt: "Search")
//        #endif
//    }
//
//    @ViewBuilder
//    func row(token: TokenData) -> some View {
//        if token.type == .totp {
//            TOTPCellView(item: token,
//                         timeInterval: visibleCells.contains { $0.id == token.id } ? $viewModel
//                             .timeRemaining : .constant(viewModel.timeRemaining))
//        } else {
//            HOTPCellView(itemId: token.id)
//        }
//    }
//
//    func favoriteListSection(tokenSection: TokenSection) -> some View {
//        Section {
//            //            if let state = viewModel.sectionsDisplayState[tokenSection.id],
//            //               !state {
//            //                EmptyView()
//            //            } else {
//            if viewModel.displayingSection(for: tokenSection.id) {
//                ForEach(tokenSection.tokens, id: \.self) { token in
//                    row(token: token)
//                        .onTapGesture {
//                            viewModel.copyToClipboard(code: token.totp)
//                        }
//
//                        .neumorphic()
//                        .listRowBackground(Color.background)
//                        .listRowSeparator(.hidden)
//                        .swipeable(leftActions: {
//                                       HStack {
//                                           Button(action: {
//                                               print("Edit ")
//                                           }) {
//                                               Label("Edit", systemImage: "pencil")
//                                                   .frame(width: 100, height: 60)
//                                                   .background(Color.blue)
//                                                   .foregroundColor(.white)
//                                                   .cornerRadius(8)
//                                           }
//                                           Button(action: {
//                                               print("Share")
//                                           }) {
//                                               Label("Share", systemImage: "square.and.arrow.up")
//                                                   .frame(width: 100, height: 60)
//                                                   .background(Color.green)
//                                                   .foregroundColor(.white)
//                                                   .cornerRadius(8)
//                                           }
//                                       }
//                                   },
//                                   rightActions: {
//                                       HStack {
//                                           Button(action: {
//                                               print("Delete")
//                                           }) {
//                                               Label("Delete", systemImage: "trash")
//                                                   .frame(maxHeight: .infinity)
//                                                   .background(Color.red)
//                                                   .foregroundColor(.white)
//                                                   .cornerRadius(8)
//                                           }
//                                       }
//                                   })
//                        //                        .swipeActions {
//                        //                            Button {
//                        //                                viewModel.toggleFavorite(token: token)
//                        //                            } label: {
//                        //                                Label("Favorite", systemImage: token.isFavorite ?
//                        //                                "star.slash" : "star")
//                        //                                    .contrastedText
//                        //                            }
//                        //                            .tint(.blue)
//                        //
//                        //                            Button {
//                        //                                router.presentedSheet = .createEditToken(token)
//                        //                            } label: {
//                        //                                Label("Edit", systemImage: "pencil")
//                        //                                    .contrastedText
//                        //                            }
//                        //                            .tint(.yellow)
//                        //
//                        //                            Button {
//                        //                                viewModel.delete(token: token)
//                        //                            } label: {
//                        //                                Label("Delete", systemImage: "trash.fill")
//                        //                                    .contrastedText
//                        //                            }
//                        //                            .tint(.error)
//                        //                        }
//                        .contextMenu {
//                            //                            Button {
//                            //                                router.presentedSheet = .createEditToken(token)
//                            //                            } label: {
//                            //                                Label("Edit", systemImage: "pencil")
//                            //                                    .baseRoundedText
//                            //                            }
//                            Button {
//                                viewModel.toggleFavorite(token: token)
//                            } label: {
//                                Label("Favorite", systemImage: token.isFavorite ? "star.slash" : "star")
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
//                }
//                .padding(.horizontal)
//            }
//        } header: {
//            HStack {
//                Text("\(tokenSection.title) (\(tokenSection.itemCount))")
//                    .bold()
//                Spacer()
//                Button { viewModel.toggleSectionDisplay(for: tokenSection.id) } label: {
//                    Image(systemName: viewModel
//                        .displayingSection(for: tokenSection.id) ? "chevron.up" : "chevron.down")
//                }
//            }
//            .padding(.horizontal)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.vertical, 10)
//            .background(.ultraThinMaterial)
//        }
//    }
//
//    //    var otherTokenSection: some View {
//    //        Section {
//    //            ForEach(viewModel.filteredTokens, id: \.self) { token in
//    //                row(token: token)
//    //                    .onTapGesture {
//    //                        viewModel.copyToClipboard(code: token.totp)
//    //                    }
//    //                    .neumorphic()
//    //                    .listRowBackground(Color.background)
//    //                    .listRowSeparator(.hidden)
//    //                    .swipeActions {
//    //                        Button {
//    //                            viewModel.toggleFavorite(token: token)
//    //                        } label: {
//    //                            Label("Favorite", systemImage: token.isFavorite ? "star.slash" : "star")
//    //                                .contrastedText
//    //                        }
//    //                        .tint(.blue)
//    //
//    //                        Button {
//    //                            router.presentedSheet = .createEditToken(token)
//    //                        } label: {
//    //                            Label("Edit", systemImage: "pencil")
//    //                                .contrastedText
//    //                        }
//    //                        .tint(.yellow)
//    //
//    //                        Button {
//    //                            viewModel.delete(token: token)
//    //                        } label: {
//    //                            Label("Delete", systemImage: "trash.fill")
//    //                                .contrastedText
//    //                        }
//    //                        .tint(.error)
//    //                    }
//    //                    .contextMenu {
//    //                        Button {
//    //                            router.presentedSheet = .createEditToken(token)
//    //                        } label: {
//    //                            Label("Edit", systemImage: "pencil")
//    //                                .baseRoundedText
//    //                        }
//    //                    }
//    //            }
//    //        } header: {
//    //            Text("Other Tokens")
//    //        }
//    //    }
// }
//
// #Preview {
//    TokensListView()
// }
//
//// struct SwipeableItem<LeftActions: View, RightActions: View>: ViewModifier {
////    @State private var offset: CGFloat = 0
////    @State private var isSwiping: Bool = false
////
////    let leftActions: () -> LeftActions
////    let rightActions: () -> RightActions
////
////    func body(content: Content) -> some View {
////        ZStack {
////            // Background actions
////            HStack {
////                // Left actions
////                leftActions()
////                Spacer()
////                // Right actions
////                rightActions()
////            }
////            .background(Color.gray.opacity(0.2))
////
////            // Foreground content
////            content
////                .background(Color.white)
////                .offset(x: offset)
////                .gesture(DragGesture()
////                    .onChanged { gesture in
////                        let dragOffset = gesture.translation.width
////                        isSwiping = true
////                        offset = dragOffset
////                    }
////                    .onEnded { _ in
////                        withAnimation {
////                            if abs(offset) > 100 { // Adjust threshold as needed
////                                offset = offset > 0 ? 120 : -120 // Button area size
////                            } else {
////                                offset = 0
////                            }
////                            isSwiping = false
////                        }
////                    })
////        }
////        .frame(maxWidth: .infinity)
////        .clipped()
////    }
//// }
////
//// extension View {
////    func swipeable(@ViewBuilder leftActions: @escaping () -> some View,
////                   @ViewBuilder rightActions: @escaping () -> some View) -> some View {
////        modifier(SwipeableItem(leftActions: leftActions, rightActions: rightActions))
////    }
//// }
//
// struct SwipeableItem<LeftActions: View, RightActions: View>: ViewModifier {
//    @State private var offset: CGFloat = 0
//    @State private var isDragging: Bool = false
//    private let buttonMaxWidth: CGFloat = 100 // Maximum width for the action buttons
//
//    let leftActions: () -> LeftActions
//    let rightActions: () -> RightActions
//
//    func body(content: Content) -> some View {
//        HStack(spacing: 0) {
//            // Left actions, dynamically resizing
//            if offset > 0 {
//                leftActions()
//                    .frame(width: offset.clamped(to: 0...buttonMaxWidth))
//            }
//
//            // Main content
//            content
//                .offset(x: offset)
//                .gesture(DragGesture()
//                    .onChanged { gesture in
//                        isDragging = true
//                        offset = gesture.translation.width
//                    }
//                    .onEnded { _ in
//                        withAnimation {
//                            if abs(offset) > buttonMaxWidth / 2 {
//                                offset = offset > 0 ? buttonMaxWidth : -buttonMaxWidth
//                            } else {
//                                offset = 0
//                            }
//                            isDragging = false
//                        }
//                    })
//
//            // Right actions, dynamically resizing
//            if offset < 0 {
//                rightActions()
//                    .frame(width: abs(offset).clamped(to: 0...buttonMaxWidth))
//            }
//        }
////        .frame(maxWidth: .infinity, alignment: .leading)
////        .background(Color.gray.opacity(0.2))
////        .cornerRadius(10)
////        .clipped()
//    }
// }
//
//// Helper to clamp values within a range
// extension Comparable {
//    func clamped(to limits: ClosedRange<Self>) -> Self {
//        min(max(self, limits.lowerBound), limits.upperBound)
//    }
// }
//
// extension View {
//    func swipeable(@ViewBuilder leftActions: @escaping () -> some View,
//                   @ViewBuilder rightActions: @escaping () -> some View) -> some View {
//        modifier(SwipeableItem(leftActions: leftActions, rightActions: rightActions))
//    }
// }

struct TokensListView: View {
    @State private var viewModel = TokensListViewModel()
    @Environment(Router.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            if let tags = viewModel.filteredTokens.tags {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            Button { viewModel.selectedtag = tag } label: {
                                Text(tag)
                                    .foregroundStyle(viewModel.selectedtag == tag ? Color.textContrast : Color
                                        .primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 7)
                                            .fill(viewModel.selectedtag == tag ? Color.main : Color.background)
                                            .stroke(Color.main, lineWidth: 2)
                                    }
//                                    .background()
//                                    .clipShape(Capsule().border(Color.main, width: 2))

                                //                                    .font(.headline)
                                //                                    .foregroundColor(.secondary)
                                //                                    .padding(.horizontal, 16)
                                //                                    .padding(.vertical, 8)
                                //                                    .background(Color.secondary.opacity(0.1))
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                }
            }
            List {
                ForEach(viewModel.filteredTokens) { section in
                    favoriteListSection(tokenSection: section)
                }

                //                .onDelete(perform: deleteEntries)
            }
            .disableBounces()
            .listStyle(.plain)
            #if os(iOS)
                .listRowSpacing(25)
            //            .listSectionSpacing(25)
            //            .contentMargins(.all, EdgeInsets(), for: .scrollContent)
            #endif

            //        ScrollView {
            //            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
            //                ForEach(viewModel.filteredTokens) { section in
            //                    favoriteListSection(tokenSection: section)
            //                }
            //            }
            //            .scrollTargetLayout()
            //        }
            //        .onScrollTargetVisibilityChange(idType: TokenData.self) { elements in
            //            visibleCells = elements
            //        }

            //            .scrollContentBackground(.hidden)
        }
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
        .navigationBarTitleDisplayMode(.inline)
        #if os(iOS)
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search")
        #endif
        #if os(iOS)
        .toolbarBackground(Color.background,
                           for: .navigationBar)
        #endif
    }

    @ViewBuilder
    func row(token: TokenData) -> some View {
        if token.type == .totp {
            TOTPCellView(item: token,
                         timeInterval:
//                         viewModel
//                             .isVisible(id: token.id) /* visibleCells.contains { $0.id == token.id }*/ ? $viewModel
//                             .timeRemaining :
                         .constant(0))
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
//                        .simultaneousGesture(onTapGesture {
//                            viewModel.copyToClipboard(code: token.totp)
//                        })

                        .neumorphic()
                        .listRowBackground(Color.background)
                        .listRowSeparator(.hidden)
//                        .swipeable(leftActions: {
//                                       HStack {
//                                           Button(action: {
//                                               print("Edit ")
//                                           }) {
//                                               Label("Edit", systemImage: "pencil")
//                                                   .frame(width: 100, height: 60)
//                                                   .background(Color.blue)
//                                                   .foregroundColor(.white)
//                                                   .cornerRadius(8)
//                                           }
//                                           Button(action: {
//                                               print("Share")
//                                           }) {
//                                               Label("Share", systemImage: "square.and.arrow.up")
//                                                   .frame(width: 100, height: 60)
//                                                   .background(Color.green)
//                                                   .foregroundColor(.white)
//                                                   .cornerRadius(8)
//                                           }
//                                       }
//                                   },
//                                   rightActions: {
//                                       HStack {
//                                           Button(action: {
//                                               print("Delete")
//                                           }) {
//                                               Label("Delete", systemImage: "trash")
//                                                   .frame(maxHeight: .infinity)
//                                                   .background(Color.red)
//                                                   .foregroundColor(.white)
//                                                   .cornerRadius(8)
//                                           }
//                                       }
//                                   })
                        .swipeActions {
                            Button {
                                viewModel.toggleFavorite(token: token)
                            } label: {
                                Label("Favorite", systemImage: token.isFavorite ?
                                    "star.slash" : "star")
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
                .listRowInsets(EdgeInsets())
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
            .padding(.top, 15)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
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

// struct SearchableSubview: View {
//    @Environment(\.isSearching) private var isSearching
//    @Binding var selectedItem: String
//    let tags: [String]
//    var body: some View {
//        if isSearching {
//            Picker("Search by", selection: $selectedItem) {
//                ForEach(tags, id: \.self) { tag in
//                    Text(tag).tag(tag)
//                }
//
//                Text("test").tag("aä")
//                Text("test2").tag("adwa")
//                Text("test3").tag("äsdad")
//            }.pickerStyle(.segmented)
//        }
//    }
// }

extension View {
    func disableBounces() -> some View {
        modifier(DisableBouncesModifier())
    }
}

struct DisableBouncesModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIScrollView.appearance().bounces = false
            }
            .onDisappear {
                UIScrollView.appearance().bounces = true
            }
    }
}
