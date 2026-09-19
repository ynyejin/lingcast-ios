//
//  SavedModels.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import Foundation

enum SavedSegment: String, CaseIterable {
    case content = "콘텐츠"
    case words = "단어/표현"
}

struct SavedStory: Identifiable {
    let id: String
    let category: String
    let level: String
    let title: String
    let durationMinutes: Int
    let artwork: HomeArtworkStyle
}

struct SavedWord: Identifiable {
    let id: String
    let term: String
    let meaning: String
    let definition: String
}

enum SavedMockData {
    static let stories: [SavedStory] = [
        SavedStory(
            id: "saved-ai-race",
            category: "TECHNOLOGY",
            level: "INTERMEDIATE",
            title: "The race to build smarter AI is on",
            durationMinutes: 6,
            artwork: .featuredAI
        ),
        SavedStory(
            id: "saved-oceans",
            category: "SCIENCE",
            level: "INTERMEDIATE",
            title: "Why our oceans are getting louder",
            durationMinutes: 4,
            artwork: .space
        )
    ]

    static let words: [SavedWord] = [
        SavedWord(id: "word-surge", term: "surge", meaning: "급증, 급증하다", definition: "a sudden large increase"),
        SavedWord(id: "word-sustainable", term: "sustainable", meaning: "지속 가능한", definition: "able to continue for a long time"),
        SavedWord(id: "word-breakthrough", term: "breakthrough", meaning: "획기적인 발전", definition: "an important discovery or development"),
        SavedWord(id: "word-resilient", term: "resilient", meaning: "회복력 있는", definition: "able to recover quickly from difficulty"),
        SavedWord(id: "word-leverage", term: "leverage", meaning: "활용하다", definition: "to use something to maximum advantage"),
        SavedWord(id: "word-implication", term: "implication", meaning: "함의, 영향", definition: "a possible effect or result of an action"),
        SavedWord(id: "word-substantial", term: "substantial", meaning: "상당한", definition: "large in amount, value, or importance"),
        SavedWord(id: "word-mitigate", term: "mitigate", meaning: "완화하다", definition: "to make something less severe or harmful"),
        SavedWord(id: "word-unprecedented", term: "unprecedented", meaning: "전례 없는", definition: "never done or known before"),
        SavedWord(id: "word-allocate", term: "allocate", meaning: "할당하다", definition: "to distribute resources for a particular purpose"),
        SavedWord(id: "word-discrepancy", term: "discrepancy", meaning: "불일치", definition: "a difference between two things that should be the same"),
        SavedWord(id: "word-underscore", term: "underscore", meaning: "강조하다", definition: "to emphasize the importance of something")
    ]
}
