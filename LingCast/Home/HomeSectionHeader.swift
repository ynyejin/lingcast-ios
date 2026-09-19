//
//  HomeSectionHeader.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct HomeSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var showsChevron: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(LingcastColor.primaryText)

            Spacer()

            if let actionTitle {
                Button(action: {}) {
                    HStack(spacing: 2) {
                        Text(actionTitle)
                        if showsChevron {
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(showsChevron ? LingcastColor.secondaryText : LingcastColor.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(actionTitle)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HomeSectionHeader(title: "추천 콘텐츠", actionTitle: "전체 보기")
        HomeSectionHeader(title: "계속 학습하기")
    }
    .padding()
    .background(LingcastColor.background)
}
