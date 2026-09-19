//
//  ProfileLevelSelector.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct ProfileLevelSelector: View {
    @Binding var selectedLevel: EnglishLevel

    var body: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            HStack {
                Text("나의 영어 수준")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)

                Spacer()

                Text(selectedLevel.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.accent)
            }

            HStack(spacing: 0) {
                ForEach(EnglishLevel.allCases, id: \.self) { level in
                    Button {
                        selectedLevel = level
                    } label: {
                        Text(level.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                selectedLevel == level
                                    ? LingcastColor.primaryText
                                    : LingcastColor.secondaryText
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedLevel == level
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
    }
}

#Preview {
    ProfileLevelSelector(selectedLevel: .constant(.intermediate))
        .padding()
        .background(LingcastColor.background)
}
