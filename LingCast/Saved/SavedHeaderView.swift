//
//  SavedHeaderView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct SavedHeaderView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("DAILYBRIEF")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(1.2)
                    .foregroundStyle(LingcastColor.secondaryText)

                Text("저장")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(LingcastColor.primaryText)

                Text("다시 듣고 싶은 이야기와 단어")
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
            }

            Spacer(minLength: 12)

            Text("A")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(LingcastColor.accent, in: Circle())
                .accessibilityLabel("프로필")
        }
    }
}

#Preview {
    SavedHeaderView()
        .padding()
        .background(LingcastColor.background)
}
