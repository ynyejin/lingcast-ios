//
//  HomePlaceholderArtwork.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct HomePlaceholderArtwork: View {
    let style: HomeArtworkStyle

    var body: some View {
        ZStack {
            LinearGradient(
                colors: palette.background,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(palette.orb.opacity(0.45))
                .frame(width: 220, height: 220)
                .blur(radius: 36)
                .offset(x: 48, y: -28)

            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 140, height: 140)
                .blur(radius: 8)
                .offset(x: -36, y: 40)

            Circle()
                .stroke(Color.white.opacity(0.18), lineWidth: 1.5)
                .frame(width: 180, height: 180)
                .offset(x: 20, y: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .allowsHitTesting(false)
    }

    private var palette: (background: [Color], orb: Color) {
        switch style {
        case .featuredAI:
            return ([LingcastColor.darkSurface, Color(red: 0.08, green: 0.18, blue: 0.42)], Color(red: 0.35, green: 0.62, blue: 1.0))
        case .appleAI:
            return ([Color(red: 0.08, green: 0.16, blue: 0.28), Color(red: 0.12, green: 0.28, blue: 0.42)], Color(red: 0.45, green: 0.78, blue: 0.92))
        case .markets:
            return ([Color(red: 0.10, green: 0.14, blue: 0.26), Color(red: 0.18, green: 0.24, blue: 0.38)], Color(red: 0.55, green: 0.66, blue: 0.86))
        case .space:
            return ([Color(red: 0.06, green: 0.08, blue: 0.22), Color(red: 0.16, green: 0.14, blue: 0.40)], Color(red: 0.50, green: 0.48, blue: 0.95))
        case .worldNews:
            return ([Color(red: 0.10, green: 0.16, blue: 0.30), Color(red: 0.20, green: 0.28, blue: 0.44)], Color(red: 0.40, green: 0.70, blue: 0.88))
        case .technology:
            return ([Color(red: 0.10, green: 0.18, blue: 0.36), Color(red: 0.16, green: 0.32, blue: 0.58)], Color(red: 0.40, green: 0.64, blue: 1.0))
        case .business:
            return ([Color(red: 0.12, green: 0.16, blue: 0.28), Color(red: 0.22, green: 0.28, blue: 0.40)], Color(red: 0.62, green: 0.70, blue: 0.84))
        case .science:
            return ([Color(red: 0.08, green: 0.16, blue: 0.30), Color(red: 0.14, green: 0.30, blue: 0.46)], Color(red: 0.42, green: 0.78, blue: 0.86))
        case .world:
            return ([Color(red: 0.11, green: 0.17, blue: 0.32), Color(red: 0.18, green: 0.26, blue: 0.42)], Color(red: 0.52, green: 0.68, blue: 0.90))
        }
    }
}

#Preview {
    HomePlaceholderArtwork(style: .featuredAI)
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding()
}
