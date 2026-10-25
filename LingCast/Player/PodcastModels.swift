//
//  PodcastModels.swift
//  LingCast
//
//  Created by 윤예진 on 10/23/26.
//


import Foundation

struct PodcastCreateResponse: Decodable {
    let podcastId: Int64
    let title: String
    let category: String
    let englishLevel: String
    let status: String
}

struct PodcastDetailResponse: Decodable {
    let podcastId: Int64
    let title: String
    let category: String
    let englishLevel: String
    let script: String?
    let audioUrl: String?
    let durationSec: Int?
    let status: String
}

struct PodcastTranscriptResponse: Decodable {
    let podcastId: Int64
    let transcript: String
    let sentences: [PodcastSentenceResponse]
}

struct PodcastSentenceResponse: Decodable {
    let sentenceIndex: Int
    let english: String
    let korean: String?
    let startMs: Int64
    let endMs: Int64
}

extension PodcastSentenceResponse {

    func toTranscriptSentence() -> TranscriptSentence {
        TranscriptSentence(
            id: sentenceIndex,
            english: english,
            korean: korean ?? "",
            vocabulary: [],
            spokenWord: ""
        )
    }
}
