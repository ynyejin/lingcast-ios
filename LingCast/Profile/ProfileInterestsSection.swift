
import SwiftUI

struct ProfileInterestsSection: View {

    let interests: [String]
    let onEdit: () -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 8)
    ]

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: HomeLayout.itemSpacing
        ) {
            HStack {
                Text("관심 분야")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)

                Spacer()

                Button("편집", action: onEdit)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.accent)
                    .buttonStyle(.plain)
            }

            LazyVGrid(
                columns: columns,
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(interests, id: \.self) { interest in
                    Button(action: onEdit) {
                        HStack(spacing: 6) {
                            Text(interest)
                            Image(systemName: "xmark")
                                .font(.caption2.weight(.bold))
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(LingcastColor.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LingcastColor.accent.opacity(0.10),
                            in: Capsule()
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(interest) 편집")
                }

                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))

                        Text("추가")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                LingcastColor.accent.opacity(0.55),
                                style: StrokeStyle(
                                    lineWidth: 1.5,
                                    dash: [5, 4]
                                )
                            )
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("관심 분야 추가")
            }
        }
    }
}

#Preview {
    ProfileInterestsSection(
        interests: ProfileMockData.interests,
        onEdit: {}
    )
    .padding()
    .background(LingcastColor.background)
}

