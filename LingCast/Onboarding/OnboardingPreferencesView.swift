
import SwiftUI

struct OnboardingPreferencesView: View {
    @Environment(AuthSession.self) private var auth

    @State private var selectedLevel: EnglishLevel = .intermediate
    @State private var selectedCategories: Set<String> = []

    @State private var isSaving = false
    @State private var errorMessage: String?

    private let categories = [
        "Tech",
        "Business",
        "Health",
        "Science",
        "Design",
        "Marketing",
        "Education",
        "Law",
        "Environment"
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                header

                ProfileLevelSelector(
                    selectedLevel: $selectedLevel
                )

                interestsSection

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                saveButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(LingcastColor.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("나만의 LingCast를\n만들어볼까요?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(LingcastColor.primaryText)

            Text("영어 수준과 관심 분야를 선택하면\n나에게 맞는 영어 뉴스를 추천해 드려요.")
                .font(.subheadline)
                .foregroundStyle(LingcastColor.secondaryText)
        }
    }

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("관심 분야")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(LingcastColor.primaryText)

            Text("관심 있는 분야를 모두 선택해주세요.")
                .font(.subheadline)
                .foregroundStyle(LingcastColor.secondaryText)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    categoryButton(category)
                }
            }
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
            HStack(spacing: 8) {
                Text(category)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                }
            }
            .foregroundStyle(
                isSelected
                    ? Color.white
                    : LingcastColor.primaryText
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .background(
                isSelected
                    ? LingcastColor.darkSurface
                    : LingcastColor.cardSurface,
                in: RoundedRectangle(cornerRadius: 14)
            )
        }
        .buttonStyle(.plain)
    }

    private var saveButton: some View {
        Button {
            Task {
                await savePreferences()
            }
        } label: {
            Text(isSaving ? "저장 중..." : "LingCast 시작하기")
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
        .disabled(selectedCategories.isEmpty || isSaving)
        .opacity(selectedCategories.isEmpty ? 0.5 : 1)
    }

    @MainActor
    private func savePreferences() async {
        guard !selectedCategories.isEmpty else { return }

        isSaving = true
        errorMessage = nil

        do {
            try await PreferenceService.shared.savePreferences(
                englishLevel: selectedLevel.rawValue.uppercased(),
                categories: selectedCategories
                    .map { $0.uppercased() }
                    .sorted()
            )

            auth.completeOnboarding()

        } catch {
            errorMessage = "설정을 저장하지 못했습니다. 다시 시도해주세요."
            print("관심사 설정 저장 실패:", error)
        }

        isSaving = false
    }
}

#Preview {
    OnboardingPreferencesView()
        .environment(AuthSession())
}

