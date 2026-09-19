//
//  ContinueLearningCard.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct ContinueLearningCard: View {
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LingcastColor.accent.opacity(0.12))
                .frame(width: 56, height: 56)
                .overlay {
                    Image(systemName: "headphones")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(LingcastColor.accent)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text("오늘 들은 뉴스에서")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(LingcastColor.secondaryText)

                Text("저장한 단어 복습하기")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)

                Text("3개의 단어가 기다리고 있어요")
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)

                progressBar
                    .padding(.top, 2)
            }

            LingcastPlayButton(size: 36)
        }
        .padding(16)
        .background(LingcastColor.cardSurface, in: RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous))
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LingcastColor.accent.opacity(0.12))

                Capsule()
                    .fill(LingcastColor.accent)
                    .frame(width: proxy.size.width * 0.38)
            }
        }
        .frame(height: 4)
    }
}

#Preview {
    ContinueLearningCard()
        .padding()
        .background(LingcastColor.background)
}
