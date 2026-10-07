//
//  AuthInputField.swift
//  LingCast
//
//  Created by 윤예진 on 10/7/26.
//

import SwiftUI

struct AuthInputField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var isSecure: Bool = false

    @State private var isPasswordVisible = false

    var body: some View {
        Group {
            if isSecure && !isPasswordVisible {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(isSecure || keyboardType == .emailAddress ? .never : .words)
                    .autocorrectionDisabled(isSecure || keyboardType == .emailAddress)
            }
        }
        .font(.body)
        .foregroundStyle(LingcastColor.primaryText)
        .textContentType(textContentType)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .padding(.trailing, isSecure ? 36 : 0)
        .background(
            LingcastColor.cardSurface,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .overlay(alignment: .trailing) {
            if isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .font(.body.weight(.medium))
                        .foregroundStyle(LingcastColor.secondaryText)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPasswordVisible ? "비밀번호 숨기기" : "비밀번호 표시")
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        AuthInputField(title: "이메일", text: .constant(""), keyboardType: .emailAddress, textContentType: .emailAddress)
        AuthInputField(title: "비밀번호", text: .constant(""), textContentType: .password, isSecure: true)
    }
    .padding()
    .background(LingcastColor.background)
}
