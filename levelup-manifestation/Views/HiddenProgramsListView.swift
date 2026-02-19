import SwiftUI

struct HiddenProgramsListView: View {
    @EnvironmentObject var theme: ThemeManager
    let area: LifeArea
    let onBack: () -> Void

    @State private var selectedProgram: HiddenProgram? = nil

    var programs: [HiddenProgram] { HiddenProgram.programs(for: area) }

    var body: some View {
        ZStack {
            if let program = selectedProgram {
                ProgramRewriteView(program: program, onBack: { selectedProgram = nil })
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                listContent
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedProgram?.id)
    }

    private var listContent: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(12)
                        .glassCard(cornerRadius: 14)
                }
                Spacer()
                Text(area.emoji)
                    .font(.system(size: 22))
                Spacer()
                // Balance
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 64)
            .padding(.bottom, 8)

            Text("These programs may be\nrunning in your subconscious")
                .font(.system(size: 22, weight: .light))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

            // Programs list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(programs) { program in
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            selectedProgram = program
                        } label: {
                            HStack {
                                Text("\"\(program.limiting)\"")
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundStyle(.white.opacity(0.85))
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.35))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .glassCard(cornerRadius: 18)
                            .shadow(color: theme.tone.glowColor, radius: 10, x: 0, y: 0)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 140)
            }
        }
    }
}
