//
//  SavedView.swift
//  LingCast
//
//  Created by 윤예진 on 9/11/26.
//

import SwiftUI

struct SavedView: View {
    @State private var selectedSegment = SavedSegment.content

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HomeLayout.sectionSpacing) {
                    SavedHeaderView()

                    SavedSegmentedControl(
                        selection: $selectedSegment,
                        wordCount: SavedMockData.words.count
                    )

                    switch selectedSegment {
                    case .content:
                        contentSection
                    case .words:
                        wordsSection
                    }
                }
                .padding(.horizontal, HomeLayout.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
            .background(LingcastColor.background.ignoresSafeArea())
            .animation(.easeInOut(duration: 0.2), value: selectedSegment)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            sectionHeader(title: "저장한 콘텐츠", countText: "\(SavedMockData.stories.count)개")

            ForEach(SavedMockData.stories) { story in
                SavedContentRow(story: story)
            }
        }
    }

    private var wordsSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            sectionHeader(title: "저장한 단어/표현", countText: "\(SavedMockData.words.count)개")
            SavedWordsList(words: SavedMockData.words)
        }
    }

    private func sectionHeader(title: String, countText: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(LingcastColor.primaryText)

            Spacer()

            Text(countText)
                .font(.subheadline)
                .foregroundStyle(LingcastColor.secondaryText)
        }
    }
}

#Preview {
    SavedView()
}
