import SwiftUI
import Forever

@main
struct ElaraApp: App {
    @Forever("name") var name: String = ""
    @DontDie("todos") var todos: [Todo] = []
    @DontLeaveMe("setupPage") var setupPage = 1
    @BePersistent("settingsData") var settingsData: SettingData = SettingData()
    @DontDie("statisticsData") var statisticsData: [Cycle] = []
    
    init() {
        _ = FontManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(name: $name, todos: $todos, setupPage: $setupPage, settingsData: $settingsData, statisticsData: $statisticsData)
                .onAppear {
                    for family in UIFont.familyNames {
                        print("Font family: \(family)")
                        for fontName in UIFont.fontNames(forFamilyName: family) {
                            print("↳ Font name: \(fontName)")
                        }
                    }
                }
        }
    }
}
