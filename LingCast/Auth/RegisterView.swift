//
//  RegisterView.swift
//  LingCast
//
//  Created by 윤예진 on 10/7/26.
//

//
//  RegisterView.swift
//  LingCast
//
//  Created by 윤예진 on 10/7/26.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss

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

        // 모든 항목 입력 여부 확인
        guard !nickname.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {
            errorMessage = "모든 항목을 입력해주세요."
            return
        }

        // 비밀번호 일치 여부 확인
        guard password == confirmPassword else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            return
        }

        isLoading = true

        do {
            _ = try await AuthService.shared.signup(
                email: email,
                password: password,
                nickname: nickname
            )

            // 회원가입 성공 시 로그인 화면으로 돌아가기
            dismiss()

        } catch {
            errorMessage = "회원가입에 실패했습니다."
            print("회원가입 실패:", error)
        }

        isLoading = false
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
