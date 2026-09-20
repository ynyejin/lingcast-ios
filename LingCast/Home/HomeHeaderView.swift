//
//  HomeHeaderView.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(LingcastColor.secondaryText)

                Text("좋은 아침이에요, Alex")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(LingcastColor.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

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

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: .now)
    }
}

#Preview {
    HomeHeaderView()
        .padding()
        .background(LingcastColor.background)
}
