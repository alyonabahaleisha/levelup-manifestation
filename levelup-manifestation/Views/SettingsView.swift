import SwiftUI

private let intervalOptions: [(label: String, minutes: Int)] = [
    ("15m", 15), ("30m", 30), ("1h", 60), ("2h", 120), ("3h", 180)
]

struct SettingsView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var notifications: NotificationManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(colors: theme.tone.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ParticlesView()

            ScrollView {
                VStack(spacing: 24) {

                    // Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 28, weight: .thin))
                            .foregroundStyle(.white)
                            .tracking(3)
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .light))
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(12)
                                .glassCard(cornerRadius: 14)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Theme
                    SettingsSection(title: "THEME") {
                        VStack(spacing: 10) {
                            ForEach(ToneTheme.allCases) { tone in
                                ToneRow(tone: tone, isSelected: theme.tone == tone) {
                                    theme.setTone(tone)
                                }
                            }
                        }
                    }

                    // Notifications
                    SettingsSection(title: "NOTIFICATIONS") {
                        VStack(spacing: 16) {

                            // Toggle
                            HStack {
                                Text("Daily affirmations")
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundStyle(.white)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { notifications.isEnabled },
                                    set: { enabled in
                                        if enabled { notifications.requestPermissionAndEnable() }
                                        else { notifications.disable() }
                                    }
                                ))
                                .tint(theme.tone.accent)
                                .labelsHidden()
                            }

                            if notifications.isEnabled {
                                Divider().background(.white.opacity(0.08))

                                // Time window — start → end in one row
                                HStack(spacing: 8) {
                                    Image(systemName: "sun.horizon")
                                        .font(.system(size: 13))
                                        .foregroundStyle(theme.tone.accent.opacity(0.7))
                                    DatePicker("", selection: $notifications.startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .onChange(of: notifications.startTime) { _, _ in notifications.scheduleNotifications() }

                                    Text("to")
                                        .font(.system(size: 13, weight: .light))
                                        .foregroundStyle(.white.opacity(0.35))

                                    DatePicker("", selection: $notifications.endTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .onChange(of: notifications.endTime) { _, _ in notifications.scheduleNotifications() }
                                    Image(systemName: "moon.stars")
                                        .font(.system(size: 13))
                                        .foregroundStyle(theme.tone.accent.opacity(0.7))
                                }

                                Divider().background(.white.opacity(0.08))

                                // Interval pills
                                HStack(spacing: 0) {
                                    Text("Every")
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .padding(.trailing, 10)
                                    HStack(spacing: 6) {
                                        ForEach(intervalOptions, id: \.minutes) { option in
                                            Button(option.label) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    notifications.intervalMinutes = option.minutes
                                                    notifications.scheduleNotifications()
                                                }
                                            }
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(notifications.intervalMinutes == option.minutes ? theme.tone.accent : .white.opacity(0.4))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .glassChip(isSelected: notifications.intervalMinutes == option.minutes, accentColor: theme.tone.accent)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer(minLength: 60)
                }
            }
        }
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.4))
                .padding(.horizontal, 24)

            content
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .glassCard(cornerRadius: 22)
                .padding(.horizontal, 16)
        }
    }
}

// MARK: - Tone Row

struct ToneRow: View {
    let tone: ToneTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Circle()
                    .fill(LinearGradient(colors: tone.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(tone.accent.opacity(isSelected ? 0.8 : 0), lineWidth: 2))
                    .shadow(color: tone.glowColor, radius: isSelected ? 8 : 0)
                Text(tone.rawValue)
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(.white.opacity(isSelected ? 1 : 0.6))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(tone.accent)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(NotificationManager())
}
