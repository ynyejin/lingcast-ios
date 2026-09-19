//
//  SavedSegmentedControl.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct SavedSegmentedControl: View {
    @Binding var selection: SavedSegment
    let wordCount: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SavedSegment.allCases, id: \.self) { segment in
                Button {
                    selection = segment
                } label: {
                    segmentLabel(segment)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selection == segment
                                ? LingcastColor.cardSurface
                                : Color.clear,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            LingcastColor.secondaryText.opacity(0.10),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    @ViewBuilder
    private func segmentLabel(_ segment: SavedSegment) -> some View {
        let isSelected = selection == segment

        switch segment {
        case .content:
            Text(segment.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? LingcastColor.primaryText : LingcastColor.secondaryText)
        case .words:
            HStack(spacing: 4) {
                Text(segment.rawValue)
                    .foregroundStyle(isSelected ? LingcastColor.primaryText : LingcastColor.secondaryText)
                Text("\(wordCount)")
                    .foregroundStyle(LingcastColor.accent)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
        }
    }
}

#Preview {
    SavedSegmentedControl(selection: .constant(.content), wordCount: 12)
        .padding()
        .background(LingcastColor.background)
}
