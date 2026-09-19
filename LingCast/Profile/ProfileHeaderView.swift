//
//  ProfileHeaderView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct ProfileHeaderView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("DAILYBRIEF")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(1.2)
                    .foregroundStyle(LingcastColor.secondaryText)

                Text("내 정보")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(LingcastColor.primaryText)

                Text("나에게 맞는 브리핑을 만들어보세요")
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
            }

            Spacer(minLength: 12)

            Text("A")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(LingcastColor.accent, in: Circle())
                .accessibilityLabel("프로필")
        }
    }
}

#Preview {
    ProfileHeaderView()
        .padding()
        .background(LingcastColor.background)
}
