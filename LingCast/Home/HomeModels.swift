//
//  HomeModels.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import Foundation

enum HomeArtworkStyle {
    case featuredAI
    case appleAI
    case markets
    case space
    case worldNews
    case technology
    case business
    case science
    case world
}

struct HomeStory: Identifiable {
    let id: String
    let category: String
    let durationMinutes: Int
    let headline: String
    let description: String
    let artwork: HomeArtworkStyle

    var metadataText: String {
        "\(category) · \(durationMinutes) MIN"
    }
}

struct HomeTopic: Identifiable {
    let id: String
    let name: String
    let artwork: HomeArtworkStyle
}

enum HomeMockData {
    static let categories = ["전체", "IT", "경제", "과학", "국제"]

    static func featuredStories(for category: String) -> [HomeStory] {
        switch category {
        case "IT":
            return itFeatured
        case "경제":
            return economyFeatured
        case "과학":
            return scienceFeatured
        case "국제":
            return worldFeatured
        default:
            return mixedFeatured
        }
    }

    static let recommended: [HomeStory] = [
        HomeStory(
            id: "rec-apple-ai",
            category: "IT",
            durationMinutes: 5,
            headline: "Apple reveals its next generation of AI",
            description: "",
            artwork: .appleAI
        ),
        HomeStory(
            id: "rec-markets",
            category: "경제",
            durationMinutes: 7,
            headline: "Why global markets are changing",
            description: "",
            artwork: .markets
        ),
        HomeStory(
            id: "rec-space",
            category: "과학",
            durationMinutes: 6,
            headline: "A new era of space exploration",
            description: "",
            artwork: .space
        ),
        HomeStory(
            id: "rec-world",
            category: "국제",
            durationMinutes: 8,
            headline: "The stories shaping the world today",
            description: "",
            artwork: .worldNews
        )
    ]

    static let topics: [HomeTopic] = [
        HomeTopic(id: "topic-technology", name: "Technology", artwork: .technology),
        HomeTopic(id: "topic-business", name: "Business", artwork: .business),
        HomeTopic(id: "topic-science", name: "Science", artwork: .science),
        HomeTopic(id: "topic-world", name: "World", artwork: .world)
    ]

    private static let mixedFeatured: [HomeStory] = [
        HomeStory(
            id: "mix-ai-race",
            category: "IT",
            durationMinutes: 6,
            headline: "The race to build smarter AI is on",
            description: "How the world's biggest tech companies are competing to build smarter AI.",
            artwork: .featuredAI
        ),
        HomeStory(
            id: "mix-markets",
            category: "경제",
            durationMinutes: 7,
            headline: "Why global markets are changing",
            description: "A closer look at the forces reshaping trade, rates, and investment.",
            artwork: .markets
        ),
        HomeStory(
            id: "mix-space",
            category: "과학",
            durationMinutes: 6,
            headline: "A new era of space exploration",
            description: "What the latest missions tell us about the decade ahead.",
            artwork: .space
        ),
        HomeStory(
            id: "mix-world",
            category: "국제",
            durationMinutes: 8,
            headline: "The stories shaping the world today",
            description: "Key global developments worth hearing this week.",
            artwork: .worldNews
        )
    ]

    private static let itFeatured: [HomeStory] = [
        HomeStory(
            id: "it-ai-race",
            category: "IT",
            durationMinutes: 6,
            headline: "The race to build smarter AI is on",
            description: "How the world's biggest tech companies are competing to build smarter AI.",
            artwork: .featuredAI
        ),
        HomeStory(
            id: "it-apple",
            category: "IT",
            durationMinutes: 5,
            headline: "Apple reveals its next generation of AI",
            description: "A first look at the features coming to iPhone and Mac.",
            artwork: .appleAI
        ),
        HomeStory(
            id: "it-chips",
            category: "IT",
            durationMinutes: 7,
            headline: "The chips powering the next wave of AI",
            description: "Why semiconductors sit at the center of the tech boom.",
            artwork: .technology
        ),
        HomeStory(
            id: "it-startups",
            category: "IT",
            durationMinutes: 5,
            headline: "The startups reshaping consumer tech",
            description: "New products quietly changing how we work and play.",
            artwork: .business
        )
    ]

    private static let economyFeatured: [HomeStory] = [
        HomeStory(
            id: "eco-markets",
            category: "경제",
            durationMinutes: 7,
            headline: "Why global markets are changing",
            description: "Investors are rewriting the playbook for a new cycle.",
            artwork: .markets
        ),
        HomeStory(
            id: "eco-rates",
            category: "경제",
            durationMinutes: 6,
            headline: "The new era of interest rates",
            description: "What shifting rates mean for households and companies.",
            artwork: .business
        ),
        HomeStory(
            id: "eco-energy",
            category: "경제",
            durationMinutes: 8,
            headline: "Energy prices and the global economy",
            description: "How fuel costs continue to shape growth and inflation.",
            artwork: .world
        ),
        HomeStory(
            id: "eco-supply",
            category: "경제",
            durationMinutes: 6,
            headline: "How supply chains are being rebuilt",
            description: "Companies are betting on resilience over speed.",
            artwork: .technology
        )
    ]

    private static let scienceFeatured: [HomeStory] = [
        HomeStory(
            id: "sci-space",
            category: "과학",
            durationMinutes: 6,
            headline: "A new era of space exploration",
            description: "Missions that could redefine what we know about the solar system.",
            artwork: .space
        ),
        HomeStory(
            id: "sci-climate",
            category: "과학",
            durationMinutes: 7,
            headline: "What climate science says now",
            description: "The latest research, without the noise.",
            artwork: .science
        ),
        HomeStory(
            id: "sci-medicine",
            category: "과학",
            durationMinutes: 5,
            headline: "Breakthroughs in medical research",
            description: "Treatments moving from the lab to everyday care.",
            artwork: .appleAI
        ),
        HomeStory(
            id: "sci-quantum",
            category: "과학",
            durationMinutes: 8,
            headline: "The quantum computers taking shape",
            description: "Why this technology is suddenly feeling closer.",
            artwork: .featuredAI
        )
    ]

    private static let worldFeatured: [HomeStory] = [
        HomeStory(
            id: "world-today",
            category: "국제",
            durationMinutes: 8,
            headline: "The stories shaping the world today",
            description: "A briefing on the week's most important global news.",
            artwork: .worldNews
        ),
        HomeStory(
            id: "world-diplomacy",
            category: "국제",
            durationMinutes: 6,
            headline: "Diplomacy in a divided world",
            description: "How governments are trying to keep conversations going.",
            artwork: .world
        ),
        HomeStory(
            id: "world-cities",
            category: "국제",
            durationMinutes: 5,
            headline: "Cities adapting to a changing climate",
            description: "Urban ideas that are starting to spread.",
            artwork: .science
        ),
        HomeStory(
            id: "world-trade",
            category: "국제",
            durationMinutes: 7,
            headline: "The next chapter of global trade",
            description: "New agreements, new tensions, and what they mean for you.",
            artwork: .markets
        )
    ]
}
