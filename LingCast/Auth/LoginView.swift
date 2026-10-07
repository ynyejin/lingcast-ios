//
//  LoginView.swift
//  LingCast
//
//  Created by 윤예진 on 10/7/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthSession.self) private var auth
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                header
                form
                loginButton
                registerRow
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .background(LingcastColor.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lingcast")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(LingcastColor.accent)

            VStack(alignment: .leading, spacing: 4) {
                Text("매일 듣는 나만의")
                Text("영어 뉴스 팟캐스트")
            }
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(LingcastColor.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var form: some View {
        VStack(spacing: 12) {
            AuthInputField(
                title: "이메일",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .username
            )

            AuthInputField(
                title: "비밀번호",
                text: $password,
                textContentType: .password,
                isSecure: true
            )

            if let errorMessage = auth.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    private var loginButton: some View {
        Button {
            Task {
                await auth.logIn(
                    email: email,
                    password: password
                )
            }
        } label: {
            Text(auth.isLoading ? "로그인 중..." : "로그인")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(LingcastColor.accent, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(auth.isLoading)
    }

    private var registerRow: some View {
        HStack(spacing: 4) {
            Text("계정이 없으신가요?")
                .foregroundStyle(LingcastColor.secondaryText)

            NavigationLink {
                RegisterView()
            } label: {
                Text("회원가입")
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.accent)
            }
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environment(AuthSession())
}
