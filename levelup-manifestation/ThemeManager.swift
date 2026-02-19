import SwiftUI
import Combine
import UserNotifications

// MARK: - Notification Manager

class NotificationManager: ObservableObject {

    @Published var isEnabled: Bool = false
    @Published var startTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @Published var endTime: Date   = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
    @Published var intervalMinutes: Int = 60  // 15, 30, 60, 120, 180

    init() { loadSettings() }

    func requestPermissionAndEnable() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isEnabled = granted
                self.saveSettings()
                if granted { self.scheduleNotifications() }
            }
        }
    }

    func disable() {
        isEnabled = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        saveSettings()
    }

    func scheduleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard isEnabled else { return }
        for (i, time) in computedTimes().enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "LevelUp ✦"
            content.body = Affirmation.all.randomElement()?.text ?? "You are becoming who you are meant to be."
            content.sound = .default
            let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            UNUserNotificationCenter.current().add(
                UNNotificationRequest(identifier: "affirmation_\(i)", content: content, trigger: trigger)
            )
        }
        saveSettings()
    }

    func computedTimes() -> [Date] {
        let cal = Calendar.current
        let s = cal.dateComponents([.hour, .minute], from: startTime)
        let e = cal.dateComponents([.hour, .minute], from: endTime)
        let startMin = (s.hour ?? 9) * 60 + (s.minute ?? 0)
        let endMin   = (e.hour ?? 18) * 60 + (e.minute ?? 0)
        guard endMin > startMin, intervalMinutes > 0 else { return [] }

        var times: [Date] = []
        var current = startMin
        while current <= endMin && times.count < 60 { // stay under iOS 64 limit
            if let date = cal.date(from: DateComponents(hour: current / 60, minute: current % 60)) {
                times.append(date)
            }
            current += intervalMinutes
        }
        return times
    }

    private func saveSettings() {
        let ud = UserDefaults.standard
        ud.set(isEnabled, forKey: "notif_enabled")
        ud.set(startTime.timeIntervalSince1970, forKey: "notif_start")
        ud.set(endTime.timeIntervalSince1970, forKey: "notif_end")
        ud.set(intervalMinutes, forKey: "notif_interval")
    }

    private func loadSettings() {
        let ud = UserDefaults.standard
        isEnabled = ud.bool(forKey: "notif_enabled")
        if ud.object(forKey: "notif_start") != nil {
            startTime = Date(timeIntervalSince1970: ud.double(forKey: "notif_start"))
        }
        if ud.object(forKey: "notif_end") != nil {
            endTime = Date(timeIntervalSince1970: ud.double(forKey: "notif_end"))
        }
        let saved = ud.integer(forKey: "notif_interval")
        if saved > 0 { intervalMinutes = saved }
    }
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    @Published var tone: ToneTheme = .softFeminine

    init() {
        if let saved = UserDefaults.standard.string(forKey: "selectedTone"),
           let tone = ToneTheme(rawValue: saved) {
            self.tone = tone
        }
    }

    func setTone(_ newTone: ToneTheme) {
        withAnimation(.easeInOut(duration: 0.5)) {
            tone = newTone
        }
        UserDefaults.standard.set(newTone.rawValue, forKey: "selectedTone")
    }

}
