//
//  CircularProgressView.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 15/12/2024.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double // Progress between 0 and 1
    var countdown: Int = 0
    var size: CGFloat = 50 // Diameter of the circle
    var lineWidth: CGFloat = 2 // Thickness of the progress bar

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(Color.gray.opacity(0.3),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size)

            // Progress Circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(countdown > 5 ? Color.blue : Color.red,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90)) // Start at the top
                .frame(width: size, height: size)

            // Timer Text
            Text("\(countdown)s")
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}
