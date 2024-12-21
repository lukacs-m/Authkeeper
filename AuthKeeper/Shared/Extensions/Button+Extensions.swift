//
//  Button+Extensions.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 20/12/2024.
//

import SwiftUI

extension Button {
    func neumorphicButtonStyle(backgroundColor: Color = .background,
                               shadowColor: Color = .neumorphicShadow,
                               highlightColor: Color = .neumorphicHighlight,
                               cornerRadius: CGFloat = 16,
                               shadowRadius: CGFloat = 10,
                               offset: CGFloat = 10) -> some View {
        buttonStyle(NeumorphicButtonStyle(backgroundColor: backgroundColor,
                                          shadowColor: shadowColor,
                                          highlightColor: highlightColor,
                                          cornerRadius: cornerRadius,
                                          shadowRadius: shadowRadius,
                                          offset: offset))
    }
}
