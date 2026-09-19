//
//  ProfileLearningStatsCard.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct ProfileLearningStatsCard: View {
    let stats: ProfileLearningStats

    var body: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            Text("학습 정보")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(LingcastColor.primaryText)

            HStack(spacing: 8) {
                stat(value: "\(stats.studiedNewsCount)", label: "학습한 뉴스")
                labeledValue(value: "\(stats.listenedMinutes)", unit: "분", label: "총 청취 시간")
                stat(value: "\(stats.savedWordCount)", label: "저장한 단어")
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                LingcastColor.cardSurface,
                in: RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous)
            )
        }
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(LingcastColor.primaryText)

            Text(label)
                .font(.caption)
                .foregroundStyle(LingcastColor.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func labeledValue(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(LingcastColor.primaryText)

            Text(label)
                .font(.caption)
                .foregroundStyle(LingcastColor.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileLearningStatsCard(stats: ProfileMockData.learningStats)
        .padding()
        .background(LingcastColor.background)
}
