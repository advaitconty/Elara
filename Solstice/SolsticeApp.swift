//
//  SolsticeApp.swift
//  Solstice
//
//  Created by Milind Contractor on 28/12/24.
//

import SwiftUI
import Forever

@main
struct SolsticeApp: App {
    @Forever("name") var name: String = ""
    @DontDie("todos") var todos: [Todo] = []
    @DontLeaveMe("setupPage") var setupPage = 1
    @BePersistent("settingsData") var settingsData: SettingData = SettingData()
    var body: some Scene {
        WindowGroup {
            ContentView(name: $name, todos: $todos, setupPage: $setupPage, settingsData: $settingsData)
        }
        
        Settings {
            SettingsView(data: $settingsData)
        }
    }
}
