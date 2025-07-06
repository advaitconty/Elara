import SwiftUI
import Forever
import SwiftData
import UserNotifications

struct ContentView: View {
    @State var name: String = ""
    @State var todos: [Todo] = []
    @State var setupPage = 1
    @Binding var settingsData: SettingData
    @State var statisticsData: [Cycle] = []
    @Query var userData: [UserData]
    @Environment(\.modelContext) var modelContext
    @State var presentPicker: Bool = false
    @AppStorage("firstApprovalForScreenTime") var firstApprovalForScreenTime: Bool = true
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    func saveData() {
        print("called saveData()")
        print(userData)
        if !userData.isEmpty {
            print("starting data save process")
            userData[0].name = name
            userData[0].todos = todos
            userData[0].setupPage = setupPage
            userData[0].settingsData = settingsData
            userData[0].cycles = statisticsData
            
            do {
                try modelContext.save()
                print("saved!")
            } catch {
                print("error saving updated data")
                print("error: \(error)")
            }
        } else {
            print("User data is empty")
            modelContext.insert(UserData(settingsData: settingsData, todos: todos, cycles: statisticsData, name: name, setupPage: setupPage))
            do {
                try modelContext.save()
                print("saved!")
            } catch {
                print("error saving new data")
                print("error: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack {
            if setupPage != 3 {
                SetupView(name: $name, todos: $todos, page: $setupPage)
                    .transition(.move(edge: .leading))
                    .preferredColorScheme(.dark)
            } else {
                TimerView(todos: $todos, name: $name, settings: $settingsData, statisticsData: $statisticsData)
                    .transition(.move(edge: .leading))
                    .preferredColorScheme(.dark)
                    .onAppear {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                            if granted {
                                settingsData.notificationsPermissionsGiven = true
                            } else {
                                settingsData.notificationsPermissionsGiven = false
                            }
                        }

                        settingsData.notificationSound = sounds.first(where: { $0.friendlyName.contains(settingsData.notificationSound.friendlyName) }) ?? sounds[0]
                    }
            }
        }
        .onChange(of: name) {
            print("name changed!")
            saveData()
        }
        .onChange(of: todos) {
            print("todos changed!")
            saveData()
        }
        .onChange(of: setupPage) {
            print("setup page changed!")
            saveData()
        }
        .onChange(of: settingsData) {
            print("settings data changed!")
            saveData()
        }
        .onChange(of: statisticsData) {
            print("statistics data changed!")
            saveData()
        }
        .onAppear {
            if let data = userData.first {
                name = data.name
                todos = data.todos
                setupPage = data.setupPage
                settingsData = data.settingsData
                statisticsData = data.cycles
            }
            
            if userData.isEmpty {
                print("adding default data")
                modelContext.insert(UserData(settingsData: SettingData(), todos: [], cycles: [], name: "", setupPage: 1))
                do {
                    try modelContext.save()
                    print("saved!")
                } catch {
                    print("error initalizing default data")
                    print("error: \(error)")
                }
            }
        }
    }
}

