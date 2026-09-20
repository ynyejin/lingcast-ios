//
//  LearnView.swift
//  LingCast
//
//  Created by 윤예진 on 9/11/26.
//

import SwiftUI

struct LearnView: View {
    @State private var isShowingLearningHistory = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HomeLayout.sectionSpacing) {
                    LearnHeaderView()

                    WeeklyLearningCard(summary: LearnMockData.weekly)

                    recentSection
                    reviewSection
                }
                .padding(.horizontal, HomeLayout.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
            .background(LingcastColor.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $isShowingLearningHistory) {
                RecentLearningView()
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            HomeSectionHeader(
                title: "최근 학습한 콘텐츠",
                actionTitle: "전체 보기",
                action: { isShowingLearningHistory = true }
            )

            ForEach(LearnMockData.recent) { item in
                RecentLearningRow(item: item)
            }
        }
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            HomeSectionHeader(title: "복습이 필요해요")

            HStack(alignment: .top, spacing: 12) {
                ForEach(LearnMockData.reviewPrompts) { prompt in
                    ReviewNeedCard(prompt: prompt)
                }
            }
        }
    }
}

#Preview {
    LearnView()
}
