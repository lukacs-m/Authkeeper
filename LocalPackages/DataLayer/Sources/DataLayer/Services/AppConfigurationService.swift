//
//  AppConfigurationService.swift
//  DataLayer
//
//  Created by Martin Lukacs on 21/12/2024.
//

import Models
import OneTimePassword
import SwiftUI
import UIKit

public enum ColorSchemeOption: String, RawRepresentable {
    case system
    case light
    case dark

    public var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            .unspecified
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}

@MainActor
public protocol AppConfigurationServicing: Sendable, Observable {
    var colorScheme: ColorSchemeOption { get set }
    var showNextTokens: Bool { get set }
    var hideTokens: Bool { get set }
}

@MainActor
@Observable
public final class AppConfigurationService: AppConfigurationServicing {
    @ObservationIgnored
    private let userDefaults: UserDefaults
    private let colorSchemeKey = "selectedColorScheme"
    private let hideTokensKey = "hideTokens"
    private let showNextTokensKey = "showNextTokens"

    public var showNextTokens: Bool = false {
        didSet {
            userDefaults.set(colorScheme.rawValue, forKey: showNextTokensKey)
        }
    }

    public var hideTokens: Bool = false {
        didSet {
            userDefaults.set(colorScheme.rawValue, forKey: hideTokensKey)
        }
    }

    public var colorScheme: ColorSchemeOption = .system {
        didSet {
//            keyWindow?.overrideUserInterfaceStyle = colorScheme.interfaceStyle
            userDefaults.set(colorScheme.rawValue, forKey: colorSchemeKey)
        }
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        setUp()
    }

    func setUp() {
        if let savedValue = userDefaults.string(forKey: colorSchemeKey),
           let scheme = ColorSchemeOption(rawValue: savedValue) {
            colorScheme = scheme
        }

        hideTokens = userDefaults.bool(forKey: hideTokensKey)
        showNextTokens = userDefaults.bool(forKey: showNextTokensKey)
    }

//
//    public func updateColorScheme(newColorScheme: ColorSchemeOption) async throws {
//        colorScheme = newColorScheme
//    }

//    var keyWindow: UIWindow? {
//        let scenes = UIApplication.shared.connectedScenes
//
//        let windowScene = scenes.first as? UIWindowScene
//
//        return windowScene?.windows.first
//
    ////        guard let window = UIApplication.shared.connectedScenes
    ////            .compactMap({ $0 as? UIWindowScene })
    ////            .flatMap(\.windows)
    ////            .first(where: { $0.isKeyWindow })
    ////        else {
    ////            return nil
    ////        }
    ////        return window
//    }
}

//
// func handleTheme(darkMode: Bool, system: Bool) {
//
//    guard !system else {
//        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
//        return
//    }
//    UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark : .light
// }
