import SwiftUI
import Forever
import SwiftData

@main
struct ElaraApp: App {
    
    init() {
        _ = FontManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: UserData.self)
        }
    }
}
