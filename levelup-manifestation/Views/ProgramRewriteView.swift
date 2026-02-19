import SwiftUI

struct ProgramRewriteView: View {
    @EnvironmentObject var theme: ThemeManager
    let program: HiddenProgram
    let onBack: () -> Void

    @State private var showRewrite = false
    @State private var saved = false

    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(12)
                        .glassCard(cornerRadius: 14)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 64)

            Spacer()

            VStack(spacing: 20) {
                // Old program
                VStack(spacing: 8) {
                    Text("OLD PROGRAM")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.35))

                    Text("\"\(program.limiting)\"")
                        .font(.system(size: 18, weight: .light))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(showRewrite ? 0.3 : 0.7))
                        .strikethrough(showRewrite, color: .white.opacity(0.3))
                        .animation(.easeInOut(duration: 0.6), value: showRewrite)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
                .glassCard(cornerRadius: 22)
                .padding(.horizontal, 24)

                // Arrow
                Image(systemName: "arrow.down")
                    .font(.system(size: 18, weight: .ultraLight))
                    .foregroundStyle(theme.tone.accent.opacity(0.7))
                    .scaleEffect(showRewrite ? 1.2 : 0.8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: showRewrite)

                // New program
                VStack(spacing: 8) {
                    Text("YOUR NEW PROGRAM")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(2)
                        .foregroundStyle(theme.tone.accent.opacity(0.7))

                    Text(program.rewrite)
                        .font(.system(size: 20, weight: .light))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 28)
                .glassCard(cornerRadius: 22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.tone.accent.opacity(showRewrite ? 0.4 : 0.1), lineWidth: 1.5)
                        .animation(.easeInOut(duration: 0.6), value: showRewrite)
                )
                .shadow(color: theme.tone.glowColor, radius: showRewrite ? 30 : 10, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.6), value: showRewrite)
                .padding(.horizontal, 24)
                .opacity(showRewrite ? 1 : 0.4)
                .animation(.easeInOut(duration: 0.5).delay(0.15), value: showRewrite)
            }

            Spacer()

            // Actions
            VStack(spacing: 12) {
                Button {
                    let notification = UINotificationFeedbackGenerator()
                    notification.notificationOccurred(.success)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        saved = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: saved ? "checkmark.circle.fill" : "sparkles")
                            .font(.system(size: 16))
                        Text(saved ? "Saved to Identity" : "Save to Identity")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(saved ? theme.tone.accent : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassCard(cornerRadius: 18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(saved ? theme.tone.accent.opacity(0.5) : Color.clear, lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 24)
                .disabled(saved)
            }
            .padding(.bottom, 140)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    showRewrite = true
                }
            }
        }
    }
}
