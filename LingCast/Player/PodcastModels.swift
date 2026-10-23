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
