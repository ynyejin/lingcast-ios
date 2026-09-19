//
//  LingcastPlayButton.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct LingcastPlayButton: View {
    var size: CGFloat = 54

    var body: some View {
        Button(action: {}) {
            Image(systemName: "play.fill")
                .font(.system(size: size * 0.32, weight: .semibold))
                .foregroundStyle(.white)
                .offset(x: 1.5)
                .frame(width: size, height: size)
                .background(LingcastColor.accent, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("재생")
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
        LingcastPlayButton()
    }
}
