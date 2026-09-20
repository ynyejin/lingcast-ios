//
//  LearnHeaderView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct LearnHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DAILYBRIEF")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(1.2)
                .foregroundStyle(LingcastColor.secondaryText)

            Text("학습")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(LingcastColor.primaryText)

            Text("어제의 나보다 한 걸음 더")
                .font(.subheadline)
                .foregroundStyle(LingcastColor.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    LearnHeaderView()
        .padding()
        .background(LingcastColor.background)
}
