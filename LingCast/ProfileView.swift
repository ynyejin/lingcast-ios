//
//  ProfileView.swift
//  LingCast
//
//  Created by 윤예진 on 9/11/26.
//

import SwiftUI

struct ProfileView: View {
    @State private var selectedLevel = EnglishLevel.intermediate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HomeLayout.sectionSpacing) {
                ProfileHeaderView()
                ProfileUserCard(user: ProfileMockData.user)
                ProfileLevelSelector(selectedLevel: $selectedLevel)
                ProfileInterestsSection(interests: ProfileMockData.interests)
                ProfileLearningStatsCard(stats: ProfileMockData.learningStats)
            }
            .padding(.horizontal, HomeLayout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .scrollIndicators(.hidden)
        .background(LingcastColor.background.ignoresSafeArea())
    }
}

#Preview {
    ProfileView()
}
