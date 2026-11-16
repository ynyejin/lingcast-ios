
import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthSession.self) private var auth

    @State private var nickname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("회원가입")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(LingcastColor.primaryText)

                form
                signupButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .background(LingcastColor.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(LingcastColor.background, for: .navigationBar)
        .tint(LingcastColor.primaryText)
    }

    // 회원가입 입력 폼
    private var form: some View {
        VStack(spacing: 12) {
            AuthInputField(
                title: "닉네임",
                text: $nickname
            )

            AuthInputField(
                title: "이메일",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            AuthInputField(
                title: "비밀번호",
                text: $password,
                textContentType: .newPassword,
                isSecure: true
            )

            AuthInputField(
                title: "비밀번호 확인",
                text: $confirmPassword,
                textContentType: .newPassword,
                isSecure: true
            )

            // 회원가입 실패 메시지
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
        }
    }

    // 회원가입 버튼
    private var signupButton: some View {
        Button {
            Task {
                await signup()
            }
        } label: {
            Text(isLoading ? "가입 중..." : "회원가입")
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
        .disabled(isLoading)
        .padding(.top, 8)
    }

    // 회원가입 API 호출
    private func signup() async {
        errorMessage = nil

        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedNickname.isEmpty,
              !trimmedEmail.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {
            errorMessage = "모든 항목을 입력해주세요."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // 1. 회원가입
            _ = try await AuthService.shared.signup(
                email: trimmedEmail,
                password: password,
                nickname: trimmedNickname
            )

        } catch {
            errorMessage = "회원가입에 실패했습니다."
            print("회원가입 실패:", error)
            return
        }

        // 2. 회원가입 성공 후 자동 로그인
        await auth.logIn(
            email: trimmedEmail,
            password: password
        )

        // 3. 자동 로그인 실패 시 안내
        if !auth.isLoggedIn {
            errorMessage = "회원가입은 완료되었지만 자동 로그인에 실패했습니다. 로그인 화면에서 다시 시도해주세요."
            return
        }

        // 로그인 성공 시 ContentView가 자동으로 화면을 전환함
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
