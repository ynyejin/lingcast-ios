//
//  ProfileModels.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import Foundation

enum EnglishLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

struct ProfileUser {
    let name: String
    let subtitle: String
    let initial: String
}

struct ProfileLearningStats {
    let studiedNewsCount: Int
    let listenedMinutes: Int
    let savedWordCount: Int
}

enum ProfileMockData {
    static let user = ProfileUser(
        name: "Alex Morgan",
        subtitle: "개인 맞춤 뉴스 팟캐스트",
        initial: "A"
    )

    static let interests = ["IT", "경제", "과학"]

    static let learningStats = ProfileLearningStats(
        studiedNewsCount: 8,
        listenedMinutes: 48,
        savedWordCount: 12
    )
}
