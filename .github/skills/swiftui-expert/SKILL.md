---
name: swiftui-expert
description: Expert guidance for building production-quality SwiftUI apps. Covers state management, animations, custom modifiers, view composition, and patterns used in the LevelUp manifestation app. Use this when writing or refactoring any SwiftUI code.
---

# SwiftUI Expert Skill

## Project Context

LevelUp is a 3-tab iOS manifestation app (Affirmations / Reprogram / Dream Life) built with:
- **SwiftUI** — declarative UI
- **Vortex** — particle effects (`ParticlesView`)
- **UserDefaults** — lightweight persistence via `@AppStorage`
- **UNUserNotificationCenter** — scheduled affirmation push notifications
- **Design system** — `ToneTheme` (softFeminine / darkMystic / goldenAbundance), glass-morphism modifiers (`glassCard`, `glassChip`, `pressable`)

---

## 1. State Management

### Choosing the right property wrapper

| Wrapper | Use when |
|---------|----------|
| `@State` | Local, view-owned value (transient UI state) |
| `@Binding` | Pass writable state down to a child view |
| `@StateObject` | Own an `ObservableObject` — create once, live with the view |
| `@ObservedObject` | Receive an `ObservableObject` from a parent |
| `@EnvironmentObject` | App-wide shared object injected at root (e.g., `ThemeManager`, `NotificationManager`) |
| `@AppStorage` | Persist a simple value in UserDefaults |

### Rules
- **Never** put `@StateObject` in a view that gets recreated frequently (e.g., list rows). Hoist it higher.
- `@State` is private — never pass it directly between views. Use `@Binding`.
- Prefer `@EnvironmentObject` over deeply chained `@Binding` for global state.

---

## 2. View Composition

### Keep views small and focused
Extract sub-views aggressively. A view body should rarely exceed ~50 lines.

```swift
// GOOD: extracted, named, reusable
struct AffirmationCard: View {
    let text: String
    var body: some View { ... }
}

// BAD: inline everything in parent
```

### Computed properties for sub-sections
Use `private var` computed properties (not nested `@ViewBuilder` functions) for readable view bodies:

```swift
var body: some View {
    VStack {
        headerSection
        contentSection
    }
}

private var headerSection: some View {
    HStack { ... }
}
```

### `@ViewBuilder` for conditional content
```swift
@ViewBuilder
private func badge(for count: Int) -> some View {
    if count > 0 {
        Text("\(count)")
            .font(.caption2)
    }
}
```

---

## 3. Animations

### Spring animations for interactive feel
```swift
withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
    isExpanded = true
}
```

### Sequenced animations with delay
```swift
// Stagger appearance
withAnimation(.easeOut(duration: 0.6).delay(0.15)) {
    logoOpacity = 1
}
withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
    taglineOpacity = 1
}
```

### Attach animation to value changes
Prefer `.animation(_:value:)` over implicit animations — it's explicit and avoids unintended cascades:
```swift
Text(label)
    .scaleEffect(isSelected ? 1.1 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
```

### Transitions for view insertion/removal
```swift
if showDetail {
    DetailView()
        .transition(.move(edge: .trailing).combined(with: .opacity))
}
// Wrap the ZStack/parent in .animation(_:value:) to drive it
```

---

## 4. Custom Modifiers (Design System)

This project's design system lives in `AppTheme.swift`. Always use these instead of raw styling:

```swift
// Glass card background (used for cards, sections)
.glassCard(cornerRadius: 22)

// Glass chip (used for pill buttons / selection chips)
.glassChip(isSelected: isSelected, accentColor: theme.tone.accent)

// Scale-on-press interaction
.pressable()
```

### Adding a new modifier
Extend `View` in `AppTheme.swift`:
```swift
extension View {
    func myNewStyle() -> some View {
        self.modifier(MyNewModifier())
    }
}

struct MyNewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.ultraThinMaterial)
    }
}
```

---

## 5. ToneTheme (Theming)

`ToneTheme` is the app's color/accent system. Always read from `@EnvironmentObject var theme: ThemeManager`.

```swift
// Gradient background (use on root ZStack)
LinearGradient(colors: theme.tone.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
    .ignoresSafeArea()

// Accent color (buttons, highlights, selected states)
.foregroundStyle(theme.tone.accent)

// Glow shadow
.shadow(color: theme.tone.glowColor, radius: 20, x: 0, y: 0)
```

Available tones: `.softFeminine`, `.darkMystic`, `.goldenAbundance`

---

## 6. Navigation Pattern

The app uses a custom `SideTabBar` with `@State var selectedTab: AppTab` in `MainTabView`. Navigation between sub-screens is done with `@State var selectedX: Model?` + `ZStack` + transitions — **not** `NavigationStack`.

```swift
// Pattern used throughout the app
ZStack {
    if let item = selectedItem {
        DetailView(item: item, onBack: { selectedItem = nil })
            .transition(.move(edge: .trailing).combined(with: .opacity))
    } else {
        ListContent
            .transition(.move(edge: .leading).combined(with: .opacity))
    }
}
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedItem?.id)
```

---

## 7. Async & Side Effects

### Use `task` for async work tied to view lifecycle
```swift
.task {
    await viewModel.loadAffirmations()
}
```

### Use `onAppear` for one-shot setup / animations
```swift
.onAppear { animate() }
```

### Use `onChange` to react to value changes
```swift
.onChange(of: notifications.startTime) { _, _ in
    notifications.scheduleNotifications()
}
```

---

## 8. Performance

- Avoid creating `ObservableObject` instances inside view bodies — use `@StateObject` or inject via environment.
- Use `LazyVStack` / `LazyHStack` inside `ScrollView` for long lists.
- Avoid heavy work in `body` — move computation into view model or `let` constants outside `body`.
- `.animation` on a parent propagates to all children — prefer scoped `.animation(_:value:)` on specific views.

---

## 9. Haptics

```swift
// Selection change (tab switch, chip selection)
UISelectionFeedbackGenerator().selectionChanged()

// Light impact (row tap)
UIImpactFeedbackGenerator(style: .light).impactOccurred()

// Success (save action)
UINotificationFeedbackGenerator().notificationOccurred(.success)
```

---

## 10. Checklist

- [ ] New views receive `ThemeManager` and `NotificationManager` via `@EnvironmentObject` — don't instantiate them locally
- [ ] Use `glassCard`, `glassChip`, `pressable` modifiers from design system
- [ ] Animations use `.spring()` or `.easeOut()` with explicit `value:` parameter
- [ ] Sub-screens follow the `selectedItem: Model?` + ZStack + transition navigation pattern
- [ ] Haptics fired on user-initiated actions
- [ ] Preview added at bottom of each file with `.environmentObject(ThemeManager())` injected
