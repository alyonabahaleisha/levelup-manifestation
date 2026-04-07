import SwiftUI
import Observation

// Mirrors Android ClubsViewModel — @Observable, ClubsUiState sealed enum
enum ClubsUiState {
    case loading
    case success(clubs: [Club], masterTelegramUrl: String)
    case error(String)
}

@Observable
@MainActor
final class ClubsViewModel {
    var uiState: ClubsUiState = .loading

    var clubs: [Club] {
        if case .success(let list, _) = uiState { return list }
        return []
    }

    var masterTelegramUrl: String {
        if case .success(_, let url) = uiState { return url }
        return Translations.ui("clubs_master_telegram_url")
    }

    var isLoading: Bool {
        if case .loading = uiState { return true }
        return false
    }

    init() {
        fetch()
    }

    func fetch() {
        uiState = .loading
        Task {
            do {
                let result = try await ClubRepository.shared.getClubs()
                uiState = .success(
                    clubs: result,
                    masterTelegramUrl: Translations.ui("clubs_master_telegram_url")
                )
            } catch {
                uiState = .error("Не удалось загрузить клубы")
            }
        }
    }
}
