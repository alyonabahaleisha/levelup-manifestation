import SwiftUI

struct AffirmationThemePickerView: View {
    let selectedThemeId: String
    let onSelect: (AffirmationTheme) -> Void
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(AffirmationTheme.all) { theme in
                        themeCard(theme)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(hex: "1C1C1E"))
            .navigationTitle("Темы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func themeCard(_ theme: AffirmationTheme) -> some View {
        Button {
            onSelect(theme)
            dismiss()
        } label: {
            ZStack {
                theme.backgroundView

                Text(theme.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.textColor)

                if theme.id == selectedThemeId {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2)
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        theme.id == selectedThemeId ? Color.white : Color.white.opacity(0.15),
                        lineWidth: theme.id == selectedThemeId ? 2 : 0.5
                    )
            )
        }
    }
}
