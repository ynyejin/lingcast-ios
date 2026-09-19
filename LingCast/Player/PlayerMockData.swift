//
//  PlayerMockData.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import Foundation

struct TranscriptSentence: Identifiable, Hashable {
    let id: Int
    let english: String
    let korean: String
    let vocabulary: [String]
    let spokenWord: String
}

struct WordDefinition: Identifiable, Hashable {
    var id: String { word.lowercased() }
    let word: String
    let koreanMeaning: String
    let englishExplanation: String
    let contextSentence: String
}

enum PlayerMockData {
    static func sentences(for episode: PlayableEpisode) -> [TranscriptSentence] {
        [
            TranscriptSentence(
                id: 0,
                english: "\(episode.headline.replacingOccurrences(of: "\n", with: " ")).",
                korean: "오늘의 핵심 이야기를 오디오로 들어보세요.",
                vocabulary: highlightedTerms(in: episode.headline),
                spokenWord: firstVocabulary(in: episode.headline)
            ),
            TranscriptSentence(
                id: 1,
                english: "The world's biggest companies are competing to build smarter systems.",
                korean: "세계 최대 기업들이 더 스마트한 시스템을 만들기 위해 경쟁하고 있습니다.",
                vocabulary: ["competing", "smarter"],
                spokenWord: "competing"
            ),
            TranscriptSentence(
                id: 2,
                english: "But intelligence is only useful when people can actually learn from it.",
                korean: "하지만 지능은 사람들이 실제로 그것으로부터 배울 수 있을 때 의미가 있습니다.",
                vocabulary: ["intelligence", "learn"],
                spokenWord: "intelligence"
            ),
            TranscriptSentence(
                id: 3,
                english: "This briefing focuses on what the story means for your everyday life.",
                korean: "이 브리핑은 이 이야기가 여러분의 일상에 어떤 의미인지를 중심으로 전합니다.",
                vocabulary: ["briefing"],
                spokenWord: "briefing"
            ),
            TranscriptSentence(
                id: 4,
                english: "Listen closely, then save the words you want to review later.",
                korean: "집중해서 듣고, 나중에 복습하고 싶은 단어는 저장해 보세요.",
                vocabulary: ["review"],
                spokenWord: "review"
            )
        ]
    }

    static func definition(for rawWord: String, contextSentence: String) -> WordDefinition {
        let word = rawWord.lowercased().trimmingCharacters(in: .punctuationCharacters)
        if let stored = definitions[word] {
            return WordDefinition(
                word: stored.word,
                koreanMeaning: stored.koreanMeaning,
                englishExplanation: stored.englishExplanation,
                contextSentence: contextSentence
            )
        }
        return WordDefinition(
            word: word,
            koreanMeaning: "이 문맥에서 중요한 표현",
            englishExplanation: "A key expression in this briefing.",
            contextSentence: contextSentence
        )
    }

    private static func highlightedTerms(in headline: String) -> [String] {
        let candidates = ["smarter", "AI", "markets", "space", "world", "companies", "oceans", "cities", "Apple"]
        return candidates.filter { headline.localizedCaseInsensitiveContains($0) }
    }

    private static func firstVocabulary(in headline: String) -> String {
        highlightedTerms(in: headline).first
            ?? headline.split(separator: " ").dropFirst().first.map(String.init)
            ?? "story"
    }

    private static let definitions: [String: WordDefinition] = [
        "smarter": WordDefinition(
            word: "smarter",
            koreanMeaning: "더 스마트한, 더 지능적인",
            englishExplanation: "More intelligent or more effective than before.",
            contextSentence: ""
        ),
        "ai": WordDefinition(
            word: "AI",
            koreanMeaning: "인공지능",
            englishExplanation: "Short for artificial intelligence; computer systems that can perform tasks that usually need human intelligence.",
            contextSentence: ""
        ),
        "competing": WordDefinition(
            word: "competing",
            koreanMeaning: "경쟁하는",
            englishExplanation: "Trying to be more successful than others in the same field.",
            contextSentence: ""
        ),
        "intelligence": WordDefinition(
            word: "intelligence",
            koreanMeaning: "지능",
            englishExplanation: "The ability to learn, understand, and make decisions.",
            contextSentence: ""
        ),
        "learn": WordDefinition(
            word: "learn",
            koreanMeaning: "배우다",
            englishExplanation: "To get knowledge or a skill by studying or experience.",
            contextSentence: ""
        ),
        "briefing": WordDefinition(
            word: "briefing",
            koreanMeaning: "브리핑, 요약 설명",
            englishExplanation: "A short, clear explanation of the most important information.",
            contextSentence: ""
        ),
        "review": WordDefinition(
            word: "review",
            koreanMeaning: "복습하다, 다시 살펴보다",
            englishExplanation: "To look at something again so you can remember or understand it better.",
            contextSentence: ""
        ),
        "markets": WordDefinition(
            word: "markets",
            koreanMeaning: "시장",
            englishExplanation: "The activity of buying and selling, or the places where that happens.",
            contextSentence: ""
        ),
        "companies": WordDefinition(
            word: "companies",
            koreanMeaning: "기업들",
            englishExplanation: "Businesses that make products or provide services.",
            contextSentence: ""
        )
    ]
}
