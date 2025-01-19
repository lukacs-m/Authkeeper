//
//
//  TokenFormView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 14/12/2024.
//
//

import Models
import OneTimePassword
import SwiftUI

struct TokenFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: TokenFormViewModel
    @State private var showAdvanceOptions: Bool = false
    @State private var showFolderCreator = false
    @State private var showTagSheet = false
    @State private var showTagCreator = false

    init(item: TokenData? = nil) {
        _viewModel = .init(wrappedValue: TokenFormViewModel(item: item))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name of Item", text: $viewModel.name)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.primaryText)
                    TextField("Service name *", text: $viewModel.issuer)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.primaryText)
                    TextField("Account *", text: $viewModel.account)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.primaryText)
                    SecureField("Secret key *", text: $viewModel.secret)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.primaryText)
                } header: {
                    Text("Base information")
                }

                Section {
                    Toggle("Favorites", isOn: $viewModel.includeInFavorite)
                        .baseRoundedText
                        .tint(.main)
                    Toggle("Widgets", isOn: $viewModel.includeInWidget)
                        .baseRoundedText
                        .tint(.main)
                } header: {
                    Text("Include in: ")
                }

                // Folder Picker Section
                Section("Folder") {
                    Picker("Select Folder", selection: $viewModel.selectedFolder) {
                        ForEach(viewModel.allFolders, id: \.self) { folder in
                            Text(folder).tag(folder)
                        }
                        Text("None").tag("")
                    }
                    .pickerStyle(.menu)

                    Button("Create a new folder") {
                        showFolderCreator = true
                    }
                }
                .alert("Add new folder", isPresented: $showFolderCreator) {
                    TextField("Folder Name", text: $viewModel.newFolderName)
                    Button("Create") {
                        viewModel.addFolder()
                    }
                    Button("Cancel", role: .cancel) {}
                }

                Section {
                    if !viewModel.tags.isEmpty {
//                        ScrollView {
                        AnyLayout(FlowLayout(spacing: 8)) {
                            ForEach(viewModel.tags, id: \.self) { tag in
                                Text(tag)
                                    .foregroundStyle(Color.textContrast)
                                    .padding(10)
                                    .background(Color.main)
                                    .clipShape(RoundedRectangle(cornerRadius: 7))
                            }
                        }
                        .padding(10)
//                        }
                    }
                } header: {
                    HStack {
                        Text("Tags")
                        Spacer()
                        Button {
                            showTagSheet.toggle()
                        } label: {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                }

                Toggle("Advance options", isOn: $showAdvanceOptions)
                    .tint(.main)

                if showAdvanceOptions {
                    Section {
                        TextField("Infos", text: $viewModel.complementaryInformation, axis: .vertical)
                    } header: {
                        Text("Additional infos")
                    }

                    Section {
                        Picker("Type", selection: $viewModel.type) {
                            ForEach(OTPType.allCases) { tokenType in
                                Text(tokenType.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)

                        switch viewModel.type {
                        case .totp:
                            Picker("Algorithm", selection: $viewModel.algo) {
                                ForEach(Generator.Algorithm.allCases) { algo in
                                    Text(algo.id)
                                        .tag(algo)
                                }
                            }
                            Stepper("Refresh time: **\(Int(viewModel.period))s**",
                                    value: $viewModel.period,
                                    step: 10)
                            Stepper("Number of digits: **\(viewModel.digits)**",
                                    value: $viewModel.digits,
                                    in: 5...9)
                        case .hotp:
                            HStack {
                                Text("Counter:")
                                TextField("Initial counter", text: $viewModel.counter)
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                #endif
                            }
                            Stepper("Number of digits: \(viewModel.digits)", value: $viewModel.digits, in: 5...9)
                        }
                    } header: {
                        Text("Advanced token settings")
                    }
                }
            }
            .navigationTitle("Manual TOTP entry")
            .background(Color.background)
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    } label: {
                        Text("Save")
                            .foregroundStyle(Color.textContrast)
                            .padding(10)
                            .background(Color.main)
                            .clipShape(Capsule())
                    }

                    .opacity(viewModel.canSave ? 1 : 0)
                }
                #endif
            }
            #if os(iOS)
            .toolbarBackground(Color.background,
                               for: .navigationBar)
            #endif
                .animation(.default, value: showAdvanceOptions)
                .animation(.default, value: viewModel.canSave)
                .sheet(isPresented: $showTagSheet) {
                    tagsList
                }
        }
    }

    private var tagsList: some View {
        NavigationStack {
            List {
                ForEach(viewModel.availableTags, id: \.self) { tag in
                    Button {
                        viewModel.toggleTag(tag: tag)
                    } label: {
                        HStack {
                            Text(tag)
                            Spacer()
                            if viewModel.tags.contains(tag) {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Add new tag", isPresented: $showTagCreator) {
                TextField("Tag Name", text: $viewModel.newTagName)
                Button("Create") {
                    viewModel.addTag()
                }
                Button("Cancel", role: .cancel) {}
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showTagCreator.toggle() } label: {
                        Text("New tag")
                            .foregroundStyle(Color.textContrast)
                            .padding(10)
                            .background(Color.main)
                            .clipShape(Capsule())
                    }
                }
                #endif
            }
        }
    }
}

#Preview {
    TokenFormView()
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes,
                      spacing: spacing,
                      containerWidth: containerWidth).size
    }

    func placeSubviews(in bounds: CGRect,
                       proposal: ProposedViewSize,
                       subviews: Subviews,
                       cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets =
            layout(sizes: sizes,
                   spacing: spacing,
                   containerWidth: bounds.width).offsets
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: .init(x: offset.x + bounds.minX,
                                    y: offset.y + bounds.minY),
                          proposal: .unspecified)
        }
    }

    func layout(sizes: [CGSize],
                spacing: CGFloat = 8,
                containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var result: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        for size in sizes {
            if currentPosition.x + size.width > containerWidth {
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            result.append(currentPosition)
            currentPosition.x += size.width
            maxX = max(maxX, currentPosition.x)
            currentPosition.x += spacing
            lineHeight = max(lineHeight, size.height)
        }
        return (result,
                .init(width: maxX, height: currentPosition.y + lineHeight))
    }
}
