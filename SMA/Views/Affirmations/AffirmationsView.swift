import SwiftUI

struct AffirmationsView: View {
    @AppStorage("affirmation_theme_id") private var selectedThemeId: String = "teal"
    @State private var affirmations: [Affirmation] = []
    @State private var showThemePicker = false
    @State private var shareAffirmation: Affirmation?

    private var theme: AffirmationTheme {
        AffirmationTheme.theme(for: selectedThemeId)
    }

    var body: some View {
        ZStack {
            theme.backgroundView.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(affirmations.enumerated()), id: \.element.id) { index, affirmation in
                        GeometryReader { geo in
                            let len = affirmation.text.count
                            let fontSize: CGFloat = len < 60 ? 34 : len < 120 ? 30 : len < 200 ? 26 : 22

                            VStack {
                                Spacer()

                                Text(affirmation.text)
                                    .font(.custom("PlayfairDisplay-Regular", size: fontSize))
                                    .foregroundColor(theme.textColor)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 32)

                                Spacer()

                                HStack(spacing: 36) {
                                    Button {
                                        shareAffirmation = affirmation
                                    } label: {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 28, weight: .light))
                                            .foregroundColor(theme.textColor.opacity(0.5))
                                    }

                                    Button {
                                    } label: {
                                        Image(systemName: "heart")
                                            .font(.system(size: 28, weight: .light))
                                            .foregroundColor(theme.textColor.opacity(0.5))
                                    }
                                }
                                .padding(.bottom, 90)
                            }
                            .frame(width: geo.size.width, height: geo.size.height)
                        }
                        .containerRelativeFrame(.vertical)
                        .id(index)
                    }
                }
            }
            .scrollTargetBehavior(.paging)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showThemePicker = true
                    } label: {
                        Image(systemName: "paintbrush.fill")
                            .font(.system(size: 16))
                            .foregroundColor(theme.textColor.opacity(0.7))
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .onAppear {
            if affirmations.isEmpty {
                affirmations = AffirmationContent.feed()
            }
        }
        .sheet(isPresented: $showThemePicker) {
            AffirmationThemePickerView(
                selectedThemeId: selectedThemeId,
                onSelect: { newTheme in
                    selectedThemeId = newTheme.id
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $shareAffirmation) { affirmation in
            AffirmationSharePreview(
                affirmation: affirmation,
                theme: theme
            )
        }
    }
}

// MARK: - Share Preview (full-screen)

private struct AffirmationSharePreview: View {
    let affirmation: Affirmation
    let theme: AffirmationTheme
    @Environment(\.dismiss) private var dismiss
    @State private var renderedImage: UIImage?

    private var deepLink: String {
        let encoded = affirmation.text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return "https://levelup.app/affirmation?text=\(encoded)"
    }

    var body: some View {
        ZStack {
            Color(hex: "1C1816").ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Card preview (scaled down to fit screen)
                let cardWidth: CGFloat = UIScreen.main.bounds.width - 64
                let cardHeight: CGFloat = cardWidth * 1.6
                AffirmationShareCard(text: affirmation.text, theme: theme)
                    .frame(width: cardWidth, height: cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.4), radius: 20, y: 10)

                Spacer()

                // Action buttons
                HStack(spacing: 16) {
                    actionButton(icon: "square.and.arrow.up", label: "Поделиться") {
                        shareImage()
                    }
                    actionButton(icon: "arrow.down.to.line", label: "Сохранить") {
                        saveImage()
                    }
                    actionButton(icon: "doc.on.doc", label: "Текст") {
                        UIPasteboard.general.string = affirmation.text
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            renderImage()
        }
    }

    @ViewBuilder
    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
                Text(label)
                    .font(.system(size: 11))
            }
            .foregroundColor(.white.opacity(0.8))
        }
    }

    @MainActor
    private func renderImage() {
        let cardWidth: CGFloat = UIScreen.main.bounds.width - 64
        let cardHeight: CGFloat = cardWidth * 1.6
        let shareView = AffirmationShareCard(text: affirmation.text, theme: theme)
            .frame(width: cardWidth, height: cardHeight)
        let renderer = ImageRenderer(content: shareView)
        renderer.scale = 3.0
        renderedImage = renderer.uiImage
    }

    @MainActor
    private func shareImage() {
        guard let image = renderedImage else { return }

        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = windowScene.windows.first?.rootViewController else { return }

        var presenter = root
        while let presented = presenter.presentedViewController {
            presenter = presented
        }
        activityVC.popoverPresentationController?.sourceView = presenter.view
        presenter.present(activityVC, animated: true)
    }

    @MainActor
    private func saveImage() {
        guard let image = renderedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

// MARK: - Share Card (rendered to image & used in preview)

struct AffirmationShareCard: View {
    let text: String
    let theme: AffirmationTheme

    var body: some View {
        ZStack {
            theme.backgroundView

            VStack(spacing: 0) {
                Spacer()

                let len = text.count
                let fontSize: CGFloat = len < 60 ? 34 : len < 120 ? 30 : len < 200 ? 26 : 22

                Text(text)
                    .font(.custom("PlayfairDisplay-Regular", size: fontSize))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)

                Spacer()

                Text("Прислано из приложения\nМихаила Агеева")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.textColor.opacity(0.35))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(theme.textColor.opacity(0.06))
                    .clipShape(Capsule())
                    .padding(.bottom, 24)
            }
        }
    }
}
