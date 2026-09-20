//
//  RecentLearningView.swift
//  LingCast
//
//  Created by 윤예진 on 9/20/26.
//

import SwiftUI

struct RecentLearningView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(LearnMockData.learningHistory) { item in
                    RecentLearningHistoryRow(item: item)
                }
            }
            .padding(.horizontal, HomeLayout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .background(LingcastColor.background.ignoresSafeArea())
        .navigationTitle("최근 학습한 콘텐츠")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(LingcastColor.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        RecentLearningView()
    }
}
