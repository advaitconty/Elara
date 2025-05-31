import FamilyControls
import ManagedSettings

func requestAuthorization() {
    AuthorizationCenter.shared.requestAuthorization { result in
        switch result {
        case .success():
            print("Authorization granted.")
        case .failure(let error):
            print("Authorization failed: \(error)")
        }
    }
}

func startPomodoroSession(with blockedApps: Set<ApplicationToken>) {
    let store = ManagedSettingsStore()
    store.shield.applications = blockedApps
}
