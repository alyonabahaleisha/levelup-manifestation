import SwiftUI

struct ReprogramView: View {
    @ObservedObject var savedProgramsVM: SavedProgramsViewModel
    @State private var selectedArea: LifeArea?
    
    var body: some View {
        ZStack {
            Color(hex: "154C6C")
                .ignoresSafeArea()

            if let area = selectedArea {
                HiddenProgramsView(area: area, savedProgramsVM: savedProgramsVM) {
                    selectedArea = nil
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                areaGrid
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4), value: selectedArea)
    }
    
    private var areaGrid: some View {
        let totalPerArea = Dictionary(uniqueKeysWithValues: LifeArea.allCases.map { ($0, ProgramContent.programs($0).count) })
        
        return ScrollView {
            VStack(spacing: 0) {
                Text(Translations.ui("reprogramTitle"))
                    .font(AppTypography.headingLarge)
                    .foregroundColor(.white)
                    .padding(.top, 80)
                
                Text(Translations.ui("reprogramSubtitle"))
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.top, 8)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(LifeArea.allCases, id: \.self) { area in
                        let savedCount = savedProgramsVM.saved.filter { $0.area == area }.count
                        let totalCount = totalPerArea[area] ?? 0
                        
                        GlassCard(cornerRadius: 20) {
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                                        .frame(width: 56, height: 56)
                                    
                                    if savedCount > 0 {
                                        Circle()
                                            .trim(from: 0, to: CGFloat(savedCount) / CGFloat(max(totalCount, 1)))
                                            .stroke(areaColor(area), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                            .frame(width: 56, height: 56)
                                            .rotationEffect(.degrees(-90))
                                    }
                                    
                                    Text(area.emoji).font(.system(size: 22))
                                }
                                
                                Text(Translations.lifeAreaLabel(area))
                                    .font(AppTypography.labelLarge)
                                    .foregroundColor(.white)
                                
                                if savedCount > 0 {
                                    Text("\(savedCount) / \(totalCount)")
                                        .font(AppTypography.caption)
                                        .foregroundColor(ToneTheme.default.accent)
                                }
                            }
                            .padding(.vertical, 24)
                            .frame(maxWidth: .infinity)
                        }
                        .onTapGesture { selectedArea = area }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Hidden Programs

struct HiddenProgramsView: View {
    let area: LifeArea
    @ObservedObject var savedProgramsVM: SavedProgramsViewModel
    var onBack: () -> Void
    @State private var selectedProgram: HiddenProgram?
    
    var body: some View {
        let programs = ProgramContent.programs(area)
        
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBack) {
                    GlassCard(cornerRadius: 14) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 44, height: 44)
                    }
                }
                Spacer()
                Text(area.emoji).font(.title)
                Spacer()
                Spacer().frame(width: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 64)

            Text(Translations.ui("hiddenProgramsSubtitle"))
                .font(AppTypography.headingMedium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(programs) { program in
                        let isReprogrammed = savedProgramsVM.saved.contains { $0.text == program.rewrite }

                        GlassCard(cornerRadius: 18) {
                            HStack {
                                Text(isReprogrammed ? program.rewrite : program.limiting)
                                    .font(AppTypography.bodyLarge)
                                    .foregroundColor(isReprogrammed ? ToneTheme.default.accent : .white.opacity(0.85))

                                Spacer()

                                Image(systemName: isReprogrammed ? "checkmark.circle" : "chevron.right")
                                    .foregroundColor(isReprogrammed ? ToneTheme.default.accent : .white.opacity(0.7))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                        }
                        .onTapGesture { selectedProgram = program }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .sheet(item: $selectedProgram) { program in
            ProgramRewriteView(program: program, savedProgramsVM: savedProgramsVM)
        }
    }
}

// MARK: - Program Rewrite

struct ProgramRewriteView: View {
    let program: HiddenProgram
    @ObservedObject var savedProgramsVM: SavedProgramsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showRewrite = false
    
    private var isSaved: Bool {
        savedProgramsVM.saved.contains { $0.text == program.rewrite }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "154C6C")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        GlassCard(cornerRadius: 14) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // Old program
                GlassCard(cornerRadius: 22) {
                    VStack(spacing: 8) {
                        Text(Translations.ui("oldProgram"))
                            .font(AppTypography.labelSmall)
                            .foregroundColor(.white.opacity(0.55))
                        Text(program.limiting)
                            .font(AppTypography.headingSmall)
                            .foregroundColor(.white.opacity(showRewrite ? 0.3 : 0.7))
                            .strikethrough(showRewrite)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                
                Image(systemName: "arrow.down")
                    .foregroundColor(ToneTheme.default.accent.opacity(0.7))
                    .scaleEffect(showRewrite ? 1.2 : 0.8)
                    .padding(.vertical, 8)
                
                // New program
                GlassCard(cornerRadius: 22) {
                    VStack(spacing: 8) {
                        Text(Translations.ui("yourNewProgram"))
                            .font(AppTypography.labelSmall)
                            .foregroundColor(ToneTheme.default.accent.opacity(0.7))
                        Text(program.rewrite)
                            .font(.custom("PlayfairDisplay-Regular", size: 20))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity)
                    .opacity(showRewrite ? 1 : 0.4)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Save button
                Button {
                    savedProgramsVM.save(program)
                } label: {
                    GlassCard(cornerRadius: 18) {
                        HStack {
                            Image(systemName: isSaved ? "checkmark.circle" : "sparkles")
                                .foregroundColor(isSaved ? ToneTheme.default.accent : .white)
                            Text(isSaved ? Translations.ui("savedToIdentity") : Translations.ui("saveToIdentity"))
                                .font(AppTypography.bodyLarge)
                                .foregroundColor(isSaved ? ToneTheme.default.accent : .white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                }
                .disabled(isSaved)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.6)) { showRewrite = true }
            }
        }
    }
}

