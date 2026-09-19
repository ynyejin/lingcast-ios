//
//  HomeMainMessageView.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct HomeMainMessageView: View {
    var body: some View {
        HStack {
            Spacer()

            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LingcastColor.primaryText)
                    .frame(width: 44, height: 44)
                    .background(LingcastColor.cardSurface, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("검색")
        }
    }
}

#Preview {
    HomeMainMessageView()
        .padding()
        .background(LingcastColor.background)
}
