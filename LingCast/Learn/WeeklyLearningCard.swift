//
//  WeeklyLearningCard.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct WeeklyLearningCard: View {
    let summary: WeeklyLearningSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .firstTextBaseline) {
                Text("이번 주 학습")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)

                Spacer()

                Text(summary.dateRangeText)
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
            }

            HStack(alignment: .top, spacing: 8) {
                stat(value: "\(summary.streakDays)", label: "연속 학습일")
                labeledValue(value: "\(summary.listenedMinutes)", unit: "분", label: "총 청취 시간")
                stat(value: "\(summary.studiedNewsCount)", label: "학습한 뉴스")
                labeledValue(value: "\(summary.quizAccuracyPercent)", unit: "%", label: "퀴즈 정답률")
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LingcastColor.cardSurface,
            in: RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous)
        )
    }

    private func stat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(LingcastColor.primaryText)

            Text(label)
                .font(.caption)
                .foregroundStyle(LingcastColor.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func labeledValue(value: String, unit: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(LingcastColor.primaryText)

                Text(unit)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(LingcastColor.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    WeeklyLearningCard(summary: LearnMockData.weekly)
        .padding()
        .background(LingcastColor.background)
}
