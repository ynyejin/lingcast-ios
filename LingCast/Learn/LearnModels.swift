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
    case completed(quizScore: String?)
    case inProgress(percent: Int)
}

struct RecentLearningItem: Identifiable {
    let id: String
    let podcastId: Int64?
    let category: String
    let level: String
    let artworkLabel: String
    let title: String
    let durationMinutes: Int
    let artwork: HomeArtworkStyle
    let status: RecentLearningStatus

    init(
        id: String,
        podcastId: Int64? = nil,
        category: String,
        level: String,
        artworkLabel: String,
        title: String,
        durationMinutes: Int,
        artwork: HomeArtworkStyle,
        status: RecentLearningStatus
    ) {
        self.id = id
        self.podcastId = podcastId
        self.category = category
        self.level = level
        self.artworkLabel = artworkLabel
        self.title = title
        self.durationMinutes = durationMinutes
        self.artwork = artwork
        self.status = status
    }
}

extension RecentLearningItem {

    init(history: PodcastHistoryResponse) {

        let durationSec = max(history.durationSec ?? 0, 0)
        let progressSec = max(history.progressSec ?? 0, 0)

        let percent: Int

        if durationSec > 0 {
            percent = min(
                Int(Double(progressSec) / Double(durationSec) * 100),
                100
            )
        } else {
            percent = 0
        }

        let status: RecentLearningStatus =
            history.completed
                ? .completed(quizScore: nil)
                : .inProgress(percent: percent)

        let artwork: HomeArtworkStyle
        let artworkLabel: String

        switch history.category.uppercased() {
        case "TECHNOLOGY":
            artwork = .technology
            artworkLabel = "TECH"
        case "WORLD":
            artwork = .worldNews
            artworkLabel = "WORLD"
        case "BUSINESS":
            artwork = .markets
            artworkLabel = "ECO"
        case "SCIENCE":
            artwork = .science
            artworkLabel = "SCI"
        default:
            artwork = .worldNews
            artworkLabel = "NEWS"
        }

        self.init(
            id: "podcast-\(history.podcastId)",
            podcastId: history.podcastId,
            category: history.category,
            level: history.englishLevel,
            artworkLabel: artworkLabel,
            title: history.title,
            durationMinutes: Int(ceil(Double(durationSec) / 60.0)),
            artwork: artwork,
            status: status
        )
    }
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

    static let learningHistory: [RecentLearningItem] = [
        RecentLearningItem(
            id: "learn-ai-chips",
            category: "TECHNOLOGY",
            level: "INTERMEDIATE",
            artworkLabel: "AI",
            title: "AI가 바꾸고 있는 반도체 산업",
            durationMinutes: 6,
            artwork: .technology,
            status: .completed(quizScore: "4/5")
        ),
        RecentLearningItem(
            id: "learn-cities",
            category: "WORLD",
            level: "INTERMEDIATE",
            artworkLabel: "WORLD",
            title: "The quiet power of better cities",
            durationMinutes: 8,
            artwork: .worldNews,
            status: .inProgress(percent: 62)
        ),
        RecentLearningItem(
            id: "learn-apple-ai",
            category: "TECHNOLOGY",
            level: "INTERMEDIATE",
            artworkLabel: "AI",
            title: "Apple reveals its next generation of AI",
            durationMinutes: 5,
            artwork: .appleAI,
            status: .inProgress(percent: 70)
        ),
        RecentLearningItem(
            id: "learn-markets",
            category: "BUSINESS",
            level: "INTERMEDIATE",
            artworkLabel: "ECO",
            title: "Why global markets are changing",
            durationMinutes: 7,
            artwork: .markets,
            status: .completed(quizScore: "5/5")
        ),
        RecentLearningItem(
            id: "learn-oceans",
            category: "SCIENCE",
            level: "INTERMEDIATE",
            artworkLabel: "SCI",
            title: "Why our oceans are getting louder",
            durationMinutes: 4,
            artwork: .science,
            status: .inProgress(percent: 45)
        ),
        RecentLearningItem(
            id: "learn-space",
            category: "SCIENCE",
            level: "ADVANCED",
            artworkLabel: "SPACE",
            title: "A new era of space exploration",
            durationMinutes: 6,
            artwork: .space,
            status: .completed(quizScore: "3/5")
        ),
        RecentLearningItem(
            id: "learn-trade",
            category: "WORLD",
            level: "INTERMEDIATE",
            artworkLabel: "WORLD",
            title: "The next chapter of global trade",
            durationMinutes: 7,
            artwork: .world,
            status: .inProgress(percent: 28)
        )
    ]

    static let recent: [RecentLearningItem] = Array(learningHistory.prefix(2))

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
