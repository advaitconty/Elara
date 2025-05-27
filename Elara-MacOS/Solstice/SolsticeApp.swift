//
//  SolsticeApp.swift
//  Solstice
//
//  Created by Milind Contractor on 28/12/24.
//

import SwiftUI
import Forever
import Cocoa

@main
struct ElaraApp: App {
    @Forever("name") var name: String = ""
    @DontDie("todos") var todos: [Todo] = []
    @DontLeaveMe("setupPage") var setupPage = 1
    @BePersistent("settingsData") var settingsData: SettingData = SettingData()
    @State var aboutWindowController: AboutWindowController?
    
    var body: some Scene {
        WindowGroup {
            ContentView(name: $name, todos: $todos, setupPage: $setupPage, settingsData: $settingsData)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Elara") {
                    showAbout()
                }
            }
        }
        
        Settings {
            SettingsView(data: $settingsData)
        }
    }
    
    private func showAbout() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        aboutWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
