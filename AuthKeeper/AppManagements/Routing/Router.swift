//
//  Router.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 15/12/2024.
//

import Models
import SwiftUI

public enum RouterDestination: Hashable {
    case appereance
}

public enum SheetDestination: Hashable, Identifiable {
    public var id: Int { hashValue }

    case createEditToken(TokenData?)
    case settings
    case barcodeScanner
}

@MainActor
@Observable
final class Router {
    var path = NavigationPath()

    var presentedSheet: SheetDestination?

    func navigate(to: RouterDestination) {
        path.append(to)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func back(to numberOfScreen: Int = 1) {
        path.removeLast(numberOfScreen)
    }
}

// @MainActor
// extension View {
////    var routingProvided: some View {
////        navigationDestination(for: RouterDestination.self) { destination in
////            switch destination {
////            case let .barDetail(bar):
////                DetailBarView(viewModel: .init(bar: bar))
////            }
////        }
////    }
//
//    func withSheetDestinations(sheetDestinations: Binding<SheetDestination?>) -> some View {
//        sheet(item: sheetDestinations) { destination in
//            switch destination {
//            case .acquisitionView:
//                AcquisitionView()
//            }
//        }
//    }
//
//    func withFullSheetDestinations(sheetDestinations: Binding<SheetDestination?>) -> some View {
//        fullScreenCover(item: sheetDestinations) { destination in
//            switch destination {
//            case .acquisitionView:
//                AcquisitionView()
//            }
//        }
//    }
// }

public struct RouterEmbeded: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .navigationDestination(for: RouterDestination.self) { destination in
                switch destination {
                case .appereance:
                    AppearanceView()
                }
            }
    }
}

public extension View {
    var routingProvided: some View {
        modifier(RouterEmbeded())
    }

    func withSheetDestinations(sheetDestinations: Binding<SheetDestination?>) -> some View {
        sheet(item: sheetDestinations) { destination in
            switch destination {
            case let .createEditToken(token):
                TokenFormView(item: token)
            case .settings:
                SettingsView()
            case .barcodeScanner:
                #if os(iOS)

                ScannerView()
                #endif
            }
        }
    }
}

//    .sheet(item: $router.presentedSheet,
//           content: { presentedSheet in
//               switch presentedSheet {
//               case let .createEditToken(token):
//                   TokenFormView(item: token)
//               case .settings:
//                   SettingsView()
//               }
//           })

//
// @Observable
// @MainActor
// public final class Router {
//  private var paths: [AppTab: [RouterDestination]] = [:]
//  public subscript(tab: AppTab) -> [RouterDestination] {
//    get { paths[tab] ?? [] }
//    set { paths[tab] = newValue }
//  }
//
//  public var selectedTab: AppTab = .feed
//
//  public var presentedSheet: SheetDestination?
//
//  public init() {}
//
//  public var selectedTabPath: [RouterDestination] {
//    paths[selectedTab] ?? []
//  }
//
//  public func popToRoot(for tab: AppTab? = nil) {
//    paths[tab ?? selectedTab] = []
//  }
//
//  public func popNavigation(for tab: AppTab? = nil) {
//    paths[tab ?? selectedTab]?.removeLast()
//  }
//
//  public func navigateTo(_ destination: RouterDestination, for tab: AppTab? = nil) {
//    paths[tab ?? selectedTab]?.append(destination)
//  }
// }
//
// extension EnvironmentValues {
//  @Entry public var currentTab: AppTab = .feed
// }
//
// public enum AppTab: String, CaseIterable, Identifiable, Hashable, Sendable {
//  case feed, notification, messages, profile, settings
//
//  public var id: String { rawValue }
//
//  public var icon: String {
//    switch self {
//    case .feed: return "square.stack"
//    case .notification: return "bell"
//    case .messages: return "message"
//    case .profile: return "person"
//    case .settings: return "gearshape"
//    }
//  }
// }
//
// @Observable
// @MainActor
// public final class Router {
//  private var paths: [AppTab: [RouterDestination]] = [:]
//  public subscript(tab: AppTab) -> [RouterDestination] {
//    get { paths[tab] ?? [] }
//    set { paths[tab] = newValue }
//  }
//
//  public var selectedTab: AppTab = .feed
//
//  public var presentedSheet: SheetDestination?
//
//  public init() {}
//
//  public var selectedTabPath: [RouterDestination] {
//    paths[selectedTab] ?? []
//  }
//
//  public func popToRoot(for tab: AppTab? = nil) {
//    paths[tab ?? selectedTab] = []
//  }
//
//  public func popNavigation(for tab: AppTab? = nil) {
//    paths[tab ?? selectedTab]?.removeLast()
//  }
//
//  public func navigateTo(_ destination: RouterDestination, for tab: AppTab? = nil) {
//    if paths[tab ?? selectedTab] == nil {
//      paths[tab ?? selectedTab] = [destination]
//    } else {
//      paths[tab ?? selectedTab]?.append(destination)
//    }
//  }
// }
