//
//  SavedHeaderView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct SavedHeaderView: View {
    var body: some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SavedHeaderView()
        .padding()
        .background(LingcastColor.background)
}
