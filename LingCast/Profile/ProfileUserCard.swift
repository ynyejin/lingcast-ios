//
//  ProfileUserCard.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct ProfileUserCard: View {
    let user: ProfileUser

    var body: some View {
        HStack(spacing: 14) {
            Text(user.initial)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(LingcastColor.accent, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)

                Text(user.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
            }

            Spacer(minLength: 8)

            Button(action: {}) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(LingcastColor.secondaryText)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("설정")
        }
        .padding(16)
        .background(
            LingcastColor.cardSurface,
            in: RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous)
        )
    }
}

#Preview {
    ProfileUserCard(user: ProfileMockData.user)
        .padding()
        .background(LingcastColor.background)
}
