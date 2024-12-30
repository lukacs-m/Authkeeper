//
//  AppConfigurationService.swift
//  DataLayer
//
//  Created by Martin Lukacs on 21/12/2024.
//

import Models
import OneTimePassword
import SwiftUI

// import UIKit

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
//
//    var interfaceStyle: UIUserInterfaceStyle {
//        switch self {
//        case .system:
//            .unspecified
//        case .light:
//            .light
//        case .dark:
//            .dark
//        }
//    }
}

// enum AppearanceType: Codable, CaseIterable, Identifiable {
//    case automatic
//    case dark
//    case light
//
//    var id: Self {
//        return self
//    }
//
//    var label: String {
//        switch self {
//        case .automatic:
//            "Automatic"
//        case .dark:
//            "Dark"
//        case .light:
//            "Light"
//        }
//    }
// }
//
// extension AppearanceType {
//    var colorScheme: ColorScheme? {
//        switch self {
//        case .automatic:
//            nil
//        case .dark:
//            .dark
//        case .light:
//            .light
//        }
//    }
// }

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

    public var showNextTokens: Bool {
        didSet {
            userDefaults.set(showNextTokens, forKey: showNextTokensKey)
        }
    }

    public var hideTokens: Bool {
        didSet {
            userDefaults.set(hideTokens, forKey: hideTokensKey)
        }
    }

    public var colorScheme: ColorSchemeOption {
        didSet {
            userDefaults.set(colorScheme.rawValue, forKey: colorSchemeKey)
        }
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        hideTokens = userDefaults.bool(forKey: hideTokensKey)
        showNextTokens = userDefaults.bool(forKey: showNextTokensKey)
        if let savedValue = userDefaults.string(forKey: colorSchemeKey),
           let scheme = ColorSchemeOption(rawValue: savedValue) {
            colorScheme = scheme
        } else {
            colorScheme = .system
        }
        setUp()
    }

    func setUp() {}
}
