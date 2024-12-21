//
//  NeumorphicStyle.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 20/12/2024.
//
import SwiftUI

struct NeumorphicStyle: ViewModifier {
    var backgroundColor: Color
    var shadowColor: Color
    var highlightColor: Color
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    var offset: CGFloat

    func body(content: Content) -> some View {
        content
            .padding()
            .background(ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .shadow(color: highlightColor, radius: shadowRadius, x: -offset, y: -offset)
                    .shadow(color: shadowColor, radius: shadowRadius, x: offset, y: offset)
                    .blendMode(.overlay)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            })
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var shadowColor: Color
    var highlightColor: Color
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    var offset: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .shadow(color: highlightColor, radius: shadowRadius, x: -offset, y: -offset)
                    .shadow(color: shadowColor, radius: shadowRadius, x: offset, y: offset)
                    .blendMode(.overlay)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            })
//            .background(RoundedRectangle(cornerRadius: cornerRadius)
//                .fill(backgroundColor)
//                .shadow(color: configuration.isPressed ? highlightColor : shadowColor,
//                        radius: shadowRadius + 4, // Deeper shadow for better visibility
//                        x: configuration.isPressed ? -offset : offset,
//                        y: configuration.isPressed ? -offset : offset)
//                .shadow(color: configuration.isPressed ? shadowColor : highlightColor,
//                        radius: shadowRadius + 4, // Brighter highlight for better elevation
//                        x: configuration.isPressed ? offset : -offset,
//                        y: configuration.isPressed ? offset : -offset))
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0) // Slightly stronger tactile response
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}
