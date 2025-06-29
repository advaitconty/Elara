import SwiftUI
import Forever

struct ContentView: View {
    @Binding var name: String
    @Binding var todos: [Todo]
    @Binding var setupPage: Int
    @Binding var settingsData: SettingData
    @Binding var statisticsData: [Cycle]
    
    var body: some View {
        if setupPage != 3 {
            SetupView(name: $name, todos: $todos, page: $setupPage)
                .transition(.slide)
                .preferredColorScheme(.dark)
        } else {
            TimerView(todos: $todos, name: $name, settings: $settingsData, statisticsData: $statisticsData)
                .transition(.slide)
                .preferredColorScheme(.dark)
                .onAppear {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                        if granted {
                            settingsData.notificationsPermissionsGiven = true
                        } else {
                            settingsData.notificationsPermissionsGiven = false
                        }
                    }
                }
        }
    }
}

