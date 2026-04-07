import SwiftUI
import MapKit

// ── Palette ────────────────────────────────────────────────────────────────────
private let mapCardBg = Color(hex: "1A2D3D")
private let mapScrimEnd = Color(hex: "0A1A28")
private let accentTeal = Color(hex: "5BB8D4")

// Geographic center of Russia — fits Kaliningrad to Vladivostok at low zoom
private let russiaCenter = CLLocationCoordinate2D(latitude: 62.0, longitude: 90.0)

// ── Public entry point ─────────────────────────────────────────────────────────

struct ClubsMapSection: View {
    let clubs: [Club]
    let onExpandMap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Наши клубы")
                .font(AppTypography.headingSmall)
                .foregroundColor(.white)

            // Preview card — 288pt total (200pt map + 88pt info zone)
            ZStack(alignment: .bottomLeading) {
                // Map layer — non-interactive
                MapPreviewLayer(clubs: clubs)
                    .frame(height: 288)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                // Gradient scrim
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .clear, location: 0.60),
                        .init(color: mapScrimEnd.opacity(0.7), location: 0.75),
                        .init(color: mapScrimEnd, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Info zone
                VStack(alignment: .leading, spacing: 4) {
                    Text("Клубы по всему миру")
                        .font(.custom("PlayfairDisplay-SemiBold", size: 18))
                        .foregroundColor(.white)

                    Text("\(clubs.count) \(cityLabel(clubs.count)) · найди ближайший")
                        .font(.custom("Manrope-Regular", size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .padding(.top, 4)

                // Expand chevron — top-right corner
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 28, height: 28)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                            .padding(12)
                    }
                    Spacer()
                }
            }
            .frame(height: 288)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .contentShape(RoundedRectangle(cornerRadius: 24))
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onExpandMap()
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Клубы по всему миру. \(clubs.count) \(cityLabel(clubs.count)). Нажмите, чтобы открыть карту.")
        }
        .padding(.horizontal, 24)
    }
}

// ── Non-interactive map preview ────────────────────────────────────────────────

private struct MapPreviewLayer: View {
    let clubs: [Club]

    // Span wide enough to fit Russia edge-to-edge
    private let region = MKCoordinateRegion(
        center: russiaCenter,
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 130)
    )

    var body: some View {
        Map(
            coordinateRegion: .constant(region),
            interactionModes: [],
            annotationItems: clubs.filter { $0.latitude != 0 || $0.longitude != 0 }
        ) { club in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: club.latitude, longitude: club.longitude)) {
                // Small dot pin — just enough to show density at preview zoom
                Circle()
                    .fill(accentTeal)
                    .frame(width: 6, height: 6)
            }
        }
        .colorScheme(.dark)
    }
}

// ── Loading skeleton ───────────────────────────────────────────────────────────

struct ClubsMapSectionSkeleton: View {
    @State private var shimmerPhase: CGFloat = -1

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(shimmerGradient)
                .frame(width: 120, height: 20)

            // Card shell
            ZStack(alignment: .bottomLeading) {
                mapCardBg

                // Map shimmer
                RoundedRectangle(cornerRadius: 0)
                    .fill(shimmerGradient)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity, alignment: .top)

                // Info zone skeletons
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 140, height: 18)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 90, height: 13)
                    Spacer().frame(height: 4)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.15))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(height: 288)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .padding(.horizontal, 24)
        .onAppear { animateShimmer() }
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "1A2D3D"), Color(hex: "243D50"), Color(hex: "1A2D3D")],
            startPoint: UnitPoint(x: shimmerPhase, y: 0),
            endPoint: UnitPoint(x: shimmerPhase + 1, y: 0)
        )
    }

    private func animateShimmer() {
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
            shimmerPhase = 1.5
        }
    }
}

// ── Empty state ────────────────────────────────────────────────────────────────

struct ClubsMapSectionEmpty: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Наши клубы")
                .font(AppTypography.headingSmall)
                .foregroundColor(.white)

            ZStack {
                mapCardBg

                VStack(spacing: 12) {
                    Text("🌐")
                        .font(.system(size: 32))
                    Text("Клубы пока недоступны")
                        .font(.custom("Manrope-SemiBold", size: 15))
                        .foregroundColor(.white)
                    Text("Заходи позже — сообщество растёт")
                        .font(.custom("Manrope-Regular", size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(24)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .padding(.horizontal, 24)
    }
}

// ── Error state ────────────────────────────────────────────────────────────────

struct ClubsMapSectionError: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Наши клубы")
                .font(AppTypography.headingSmall)
                .foregroundColor(.white)

            ZStack {
                mapCardBg

                VStack(spacing: 12) {
                    Text("Нет подключения к сети")
                        .font(.custom("Manrope-SemiBold", size: 15))
                        .foregroundColor(.white)
                    Text("Проверь интернет и попробуй снова")
                        .font(.custom("Manrope-Regular", size: 13))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer().frame(height: 4)
                    Button(action: onRetry) {
                        Text("Обновить")
                            .font(.custom("Manrope-SemiBold", size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(accentTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .padding(.horizontal, 24)
    }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

/// Russian plural for город / города / городов
private func cityLabel(_ count: Int) -> String {
    let mod100 = count % 100
    let mod10 = count % 10
    switch (mod100, mod10) {
    case (11...19, _): return "городов"
    case (_, 1):       return "город"
    case (_, 2...4):   return "города"
    default:           return "городов"
    }
}

func openUrl(_ urlString: String) {
    guard !urlString.isEmpty, let url = URL(string: urlString) else { return }
    UIApplication.shared.open(url)
}
