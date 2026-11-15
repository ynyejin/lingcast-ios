
import SwiftUI

struct CategoryFilterView: View {
    @Binding var selectedCategory: String

    var body: some View {
        CategoryFlowLayout(spacing: 8) {
            ForEach(HomeMockData.categories, id: \.self) { category in
                categoryChip(category)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func categoryChip(_ category: String) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            selectedCategory = category
        } label: {
            Text(category)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(
                    isSelected
                        ? Color.white
                        : LingcastColor.primaryText
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    isSelected
                        ? LingcastColor.darkSurface
                        : LingcastColor.cardSurface,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }
}

// 화면 너비에 맞춰 카테고리를 자동 줄바꿈하는 레이아웃
private struct CategoryFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? 350
        let layout = arrange(subviews: subviews, width: width)
        return CGSize(width: width, height: layout.height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let layout = arrange(
            subviews: subviews,
            width: bounds.width
        )

        for (index, point) in layout.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + point.x,
                    y: bounds.minY + point.y
                ),
                proposal: .unspecified
            )
        }
    }

    private func arrange(
        subviews: Subviews,
        width: CGFloat
    ) -> (positions: [CGPoint], height: CGFloat) {
        var positions: [CGPoint] = []

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x > 0 && x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: x, y: y))

            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        return (
            positions,
            y + rowHeight
        )
    }
}

#Preview {
    CategoryFilterView(selectedCategory: .constant("All"))
        .padding()
        .background(LingcastColor.background)
}

