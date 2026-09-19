//
//  LearnModels.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import Foundation

struct WeeklyLearningSummary {
    let dateRangeText: String
    let streakDays: Int
    let listenedMinutes: Int
    let studiedNewsCount: Int
    let quizAccuracyPercent: Int
}

enum RecentLearningStatus {
    case completed(quizScore: String)
    case inProgress(percent: Int)
}

struct RecentLearningItem: Identifiable {
    let id: String
    let category: String
    let level: String
    let artworkLabel: String
    let title: String
    let status: RecentLearningStatus
}

struct ReviewPrompt: Identifiable {
    let id: String
    let iconName: String
    let title: String
    let actionTitle: String
    let usesWarmAccent: Bool
}

enum LearnMockData {
    static let weekly = WeeklyLearningSummary(
        dateRangeText: "9월 8–12일",
        streakDays: 4,
        listenedMinutes: 48,
        studiedNewsCount: 8,
        quizAccuracyPercent: 86
    )

    static let recent: [RecentLearningItem] = [
        RecentLearningItem(
            id: "learn-ai-chips",
            category: "TECHNOLOGY",
            level: "INTERMEDIATE",
            artworkLabel: "AI",
            title: "AI가 바꾸고 있는 반도체 산업",
            status: .completed(quizScore: "4/5")
        ),
        RecentLearningItem(
            id: "learn-cities",
            category: "WORLD",
            level: "INTERMEDIATE",
            artworkLabel: "WORLD",
            title: "The quiet power of better cities",
            status: .inProgress(percent: 62)
        )
    ]

    static let reviewPrompts: [ReviewPrompt] = [
        ReviewPrompt(
            id: "review-words",
            iconName: "bookmark",
            title: "저장한 단어 12개",
            actionTitle: "짧게 복습하기",
            usesWarmAccent: false
        ),
        ReviewPrompt(
            id: "review-quiz",
            iconName: "arrow.counterclockwise",
            title: "틀린 문제 4개",
            actionTitle: "다시 풀어보기",
            usesWarmAccent: true
        )
    ]
}
