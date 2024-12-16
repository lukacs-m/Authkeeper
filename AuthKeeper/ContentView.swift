//
//  ContentView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 28/07/2024.
//

// import SwiftData
// import SwiftUI
//
// struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
//
//    var body: some View {
//        NavigationSplitView {
////            List {
////                ForEach(items) { item in
////                    NavigationLink {
////                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time:
////                        .standard))")
////                    } label: {
////                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
////                    }
////                    .sensoryFeedback(.impact(flexibility: .soft), trigger: items)
////                }
////                .onDelete(perform: deleteItems)
////            }
//            List {
//                ForEach(entries) { entry in
//                    VStack(alignment: .leading) {
//                        Text("\(entry.issuer) - \(entry.account)")
//                            .font(.headline)
//                        if let code = entry.generateTOTP() {
//                            HStack {
//                                Text(code)
//                                    .font(.title)
//                                    .bold()
//                                Spacer()
//                                Text("\(Int(entry.remainingTime()))s")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                    }
//                }
////                .onDelete(perform: deleteEntries)
//            }
//            .navigationTitle("AuthKeeper")
//            #if os(macOS)
//                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
//            #endif
//                .toolbar {
//                    #if os(iOS)
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        EditButton()
//                    }
//                    #endif
//                    ToolbarItem {
//                        Button(action: addItem) {
//                            Label("Add Item", systemImage: "plus")
//                        }
//                    }
//                }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
// }
//
// #Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
// }
