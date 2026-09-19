//
//  CategoryFilterView.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct CategoryFilterView: View {
    @Binding var selectedCategory: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(HomeMockData.categories, id: \.self) { category in
                    categoryChip(category)
                }
            }
        }
    }

    private func categoryChip(_ category: String) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            selectedCategory = category
        } label: {
            Text(category)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? Color.white : LingcastColor.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? LingcastColor.darkSurface : LingcastColor.cardSurface, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryFilterView(selectedCategory: .constant("전체"))
        .padding()
        .background(LingcastColor.background)
}
