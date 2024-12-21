//
//  View+Extensions.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 20/12/2024.
//

import SwiftUI

// MARK: - Basic UI elements styles

extension View {
    var baseRoundedText: some View {
        font(.system(.body, design: .rounded))
            .foregroundStyle(.primaryText)
    }

    var contrastedText: some View {
        font(.system(.body, design: .rounded))
            .foregroundStyle(.textContrast)
    }
}

// MARK: - Neumorphic elemnts

extension View {
    func neumorphic(backgroundColor: Color = .background,
                    shadowColor: Color = .neumorphicShadow,
                    highlightColor: Color = .neumorphicHighlight,
                    cornerRadius: CGFloat = 16,
                    shadowRadius: CGFloat = 10,
                    offset: CGFloat = 10) -> some View {
        modifier(NeumorphicStyle(backgroundColor: backgroundColor,
                                 shadowColor: shadowColor,
                                 highlightColor: highlightColor,
                                 cornerRadius: cornerRadius,
                                 shadowRadius: shadowRadius,
                                 offset: offset))
    }
}
