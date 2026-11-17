
import SwiftUI

struct ProfileInterestsEditView: View {

    @Environment(\.dismiss) private var dismiss

    let englishLevel: String
    let onSave: ([String]) -> Void

    @State private var selectedCategories: Set<String>
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let categories = [
        "TECH", "BUSINESS", "HEALTH",
        "SCIENCE", "DESIGN", "MARKETING",
        "EDUCATION", "LAW", "ENVIRONMENT"
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(
        selectedCategories: [String],
        englishLevel: String,
        onSave: @escaping ([String]) -> Void
    ) {
        self.englishLevel = englishLevel
        self.onSave = onSave
        _selectedCategories = State(
            initialValue: Set(selectedCategories)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("관심 분야 수정")
                            .font(.title2.bold())
                            .foregroundStyle(LingcastColor.primaryText)

                        Text("관심 있는 분야를 선택해주세요.")
                            .font(.subheadline)
                            .foregroundStyle(LingcastColor.secondaryText)
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            categoryButton(category)
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task {
                            await savePreferences()
                        }
                    } label: {
                        Text(isSaving ? "저장 중..." : "변경사항 저장")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LingcastColor.accent,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        isSaving || selectedCategories.isEmpty
                    )
                    .opacity(
                        selectedCategories.isEmpty ? 0.5 : 1
                    )
                }
                .padding(24)
            }
            .background(LingcastColor.background.ignoresSafeArea())
            .navigationTitle("관심 분야")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("취소") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
            }
            .interactiveDismissDisabled(isSaving)
        }
    }

    private func categoryButton(_ category: String) -> some View {
        let isSelected = selectedCategories.contains(category)

        return Button {
            if isSelected {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
        } label: {
            HStack {
                Text(category.capitalized)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Image(systemName: "circle")
                }
            }
            .foregroundStyle(
                isSelected
                    ? LingcastColor.accent
                    : LingcastColor.primaryText
            )
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                    ? LingcastColor.accent.opacity(0.12)
                    : LingcastColor.cardSurface,
                in: RoundedRectangle(cornerRadius: 14)
            )
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
    }

    @MainActor
    private func savePreferences() async {
        guard !selectedCategories.isEmpty else {
            errorMessage = "관심 분야를 하나 이상 선택해주세요."
            return
        }

        isSaving = true
        errorMessage = nil

        let updatedCategories = categories.filter {
            selectedCategories.contains($0)
        }

        do {
            try await PreferenceService.shared.updatePreferences(
                englishLevel: englishLevel,
                categories: updatedCategories
            )

            onSave(updatedCategories)
            dismiss()

        } catch {
            errorMessage = "관심 분야 저장에 실패했습니다."
            print("관심 분야 변경 실패:", error)
        }

        isSaving = false
    }
}

#Preview {
    ProfileInterestsEditView(
        selectedCategories: ["TECH", "DESIGN"],
        englishLevel: "INTERMEDIATE",
        onSave: { _ in }
    )
}

