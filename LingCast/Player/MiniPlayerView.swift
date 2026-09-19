//
//  MiniPlayerView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct MiniPlayerView: View {
    @Bindable var playback: PlaybackSession

    var body: some View {
        if let episode = playback.episode {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button {
                        playback.isPlayerPresented = true
                    } label: {
                        HStack(spacing: 12) {
                            HomePlaceholderArtwork(style: episode.artwork)
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                            Text(episode.headline)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        playback.isPlaying.toggle()
                    } label: {
                        Image(systemName: playback.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .offset(x: playback.isPlaying ? 0 : 1)
                            .frame(width: 32, height: 32)
                            .background(LingcastColor.accent, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(playback.isPlaying ? "일시정지" : "재생")

                    Button {
                        playback.stop()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.45))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("재생 종료")
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.12))

                        Rectangle()
                            .fill(LingcastColor.accent)
                            .frame(width: max(proxy.size.width * playback.progress, 0))
                    }
                }
                .frame(height: 3)
            }
            .background(LingcastColor.darkSurface)
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(.isButton)
        }
    }
}
