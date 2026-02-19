import SwiftUI
import Combine
import UserNotifications

// MARK: - Notification Manager
// ANDROID: NotificationViewModel.kt (HiltViewModel)
//   Uses NotificationManagerCompat + AlarmManager for scheduling
//   Persist settings with DataStore<Preferences>:
//     NOTIF_ENABLED, NOTIF_START_HOUR, NOTIF_START_MIN, NOTIF_END_HOUR, NOTIF_END_MIN, NOTIF_INTERVAL
//   requestPermissionAndEnable() → ActivityResultLauncher<String> for POST_NOTIFICATIONS permission
//   scheduleNotifications() → AlarmManager.setRepeating() per computed time slot
//   disable() → AlarmManager.cancel() for all pending intents + NotificationManagerCompat.cancelAll()

class NotificationManager: ObservableObject {

    // ANDROID: val isEnabled: StateFlow<Boolean>
    @Published var isEnabled: Bool = false
    // ANDROID: val startTime: StateFlow<LocalTime> (default 09:00)
    @Published var startTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    // ANDROID: val endTime: StateFlow<LocalTime> (default 18:00)
    @Published var endTime: Date   = Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
    // ANDROID: val intervalMinutes: StateFlow<Int> — options: 15, 30, 60, 120, 180
    @Published var intervalMinutes: Int = 60

    init() { loadSettings() }

    // ANDROID: fun requestPermissionAndEnable() — launch POST_NOTIFICATIONS permission request
    //   on granted: isEnabled = true, saveSettings(), scheduleNotifications()
    func requestPermissionAndEnable() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isEnabled = granted
                self.saveSettings()
                if granted { self.scheduleNotifications() }
            }
        }
    }

    // ANDROID: fun disable() — cancel all AlarmManager intents, isEnabled = false, saveSettings()
    func disable() {
        isEnabled = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        saveSettings()
    }

    // ANDROID: fun scheduleNotifications()
    //   val times = computedTimes()
    //   times.forEachIndexed { i, (hour, min) ->
    //     val intent = Intent(context, AffirmationReceiver::class.java)
    //     val pendingIntent = PendingIntent.getBroadcast(context, i, intent, FLAG_UPDATE_CURRENT or FLAG_IMMUTABLE)
    //     alarmManager.setRepeating(AlarmManager.RTC_WAKEUP, triggerAtMillis, AlarmManager.INTERVAL_DAY, pendingIntent)
    //   }
    //   AffirmationReceiver is a BroadcastReceiver that posts the notification via NotificationManagerCompat
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

    // ANDROID: fun computedTimes(): List<Pair<Int, Int>>  (hour, minute pairs)
    //   val startMin = startHour * 60 + startMinute
    //   val endMin = endHour * 60 + endMinute
    //   generateSequence(startMin) { it + intervalMinutes }.takeWhile { it <= endMin }.take(60)
    //     .map { Pair(it / 60, it % 60) }.toList()
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

    // ANDROID: private fun saveSettings() — DataStore<Preferences>.edit { prefs -> ... }
    private func saveSettings() {
        let ud = UserDefaults.standard
        ud.set(isEnabled, forKey: "notif_enabled")
        ud.set(startTime.timeIntervalSince1970, forKey: "notif_start")
        ud.set(endTime.timeIntervalSince1970, forKey: "notif_end")
        ud.set(intervalMinutes, forKey: "notif_interval")
    }

    // ANDROID: private fun loadSettings() — dataStore.data.first() in viewModelScope
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
// ANDROID: ThemeViewModel.kt (HiltViewModel)
//   val tone: StateFlow<ToneTheme> = dataStore.data.map { it[TONE_KEY] ?: ToneTheme.SOFT_FEMININE }
//   fun setTone(newTone: ToneTheme) — dataStore.edit { it[TONE_KEY] = newTone.name }
//   Provide theme via CompositionLocal: LocalTheme = staticCompositionLocalOf { ToneTheme.SOFT_FEMININE }

class ThemeManager: ObservableObject {
    // ANDROID: val tone = MutableStateFlow(ToneTheme.SOFT_FEMININE) backed by DataStore
    @Published var tone: ToneTheme = .softFeminine

    init() {
        if let saved = UserDefaults.standard.string(forKey: "selectedTone"),
           let tone = ToneTheme(rawValue: saved) {
            self.tone = tone
        }
    }

    // ANDROID: fun setTone(newTone: ToneTheme) — update StateFlow + persist to DataStore
    func setTone(_ newTone: ToneTheme) {
        withAnimation(.easeInOut(duration: 0.5)) {
            tone = newTone
        }
        UserDefaults.standard.set(newTone.rawValue, forKey: "selectedTone")
    }

}
