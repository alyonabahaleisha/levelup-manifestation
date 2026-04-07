import SwiftUI
import MapKit

// Full-screen clubs map — mirrors Android ClubsMapScreen.kt

// ── Palette ────────────────────────────────────────────────────────────────────
private let screenBg   = Color(hex: "0D1E2A")
private let topBarBg   = Color(hex: "0D1E2A").opacity(0.90)
private let sheetBg    = Color(hex: "1A2D3D")
private let accentTeal = Color(hex: "5BB8D4")
private let accentTealDark = Color(hex: "3A8FA8")
private let telegramBlue = Color(hex: "2AABEE")
private let barBorder  = Color.white.opacity(0.08)

// ── Public entry point ─────────────────────────────────────────────────────────

struct ClubsMapScreen: View {
    let clubs: [Club]
    let isLoading: Bool
    let onDismiss: () -> Void

    @State private var selectedClub: Club? = nil

    var body: some View {
        ZStack {
            screenBg.ignoresSafeArea()

            // Interactive map — full bleed
            ClubMapView(clubs: clubs, selectedClub: $selectedClub)
                .ignoresSafeArea()
                .accessibilityLabel("Интерактивная карта клубов. На карте отображено \(clubs.count) городов.")

            // Loading overlay
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white.opacity(0.7))
                        .scaleEffect(0.9)
                    Text("Загружаем клубы...")
                        .font(.custom("Manrope-Regular", size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Empty state overlay
            if !isLoading && clubs.isEmpty {
                VStack {
                    Spacer()
                    Text("Клубы пока не загружены. Попробуй вернуться позже.")
                        .font(.custom("Manrope-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(24)
                        .frame(width: 280)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Top bar — layered over map
            VStack(spacing: 0) {
                MapTopBar(onDismiss: onDismiss)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Club detail sheet on pin tap
        .sheet(item: $selectedClub) { club in
            ClubDetailSheet(club: club, onClose: { selectedClub = nil })
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
                .presentationBackground(sheetBg)
                .presentationCornerRadius(20)
        }
    }
}

// MARK: - Top bar ───────────────────────────────────────────────────────────────

private struct MapTopBar: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Вернуться на главный экран")
                .padding(.leading, 16)

                Spacer()

                Text("Наши клубы")
                    .font(.custom("Manrope-SemiBold", size: 17))
                    .foregroundColor(.white)

                Spacer()

                Color.clear.frame(width: 52, height: 36)
            }
            .frame(height: 56)
            .overlay(alignment: .bottom) {
                barBorder.frame(height: 1)
            }
        }
        .background(topBarBg)
    }
}

// MARK: - Club detail sheet ─────────────────────────────────────────────────────

private struct ClubDetailSheet: View {
    let club: Club
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // City + close
            HStack(alignment: .center) {
                Text(club.city)
                    .font(.custom("PlayfairDisplay-Regular", size: 22))
                    .foregroundColor(.white)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .accessibilityLabel("Закрыть информацию о клубе")
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Spacer().frame(height: 12)

            // Leader
            Text("Руководитель клуба")
                .font(.custom("Manrope-Regular", size: 12))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 24)

            Spacer().frame(height: 4)

            Text(club.leaderName.isEmpty ? "—" : club.leaderName)
                .font(.custom("Manrope-SemiBold", size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 24)

            Spacer().frame(height: 20)

            // Telegram button
            Button {
                openUrl(club.telegramUrl)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                    Text("Открыть в Telegram")
                        .font(.custom("Manrope-SemiBold", size: 15))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(telegramBlue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .accessibilityLabel("Открыть клуб \(club.city) в Telegram. Откроет внешнее приложение.")

            Spacer().frame(height: 24)
        }
    }
}

// Club must be Identifiable for .sheet(item:) — already conforms via Models.swift
