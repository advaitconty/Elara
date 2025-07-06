//
//  SolsticeApp.swift
//  Solstice
//
//  Created by Milind Contractor on 28/12/24.
//

import SwiftUI
import Forever
import Cocoa
import UserNotifications
import SwiftData

@main
struct ElaraApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State var aboutWindowController: AboutWindowController?
    @Environment(\.openWindow) private var openWindow
    @State var settingsData: SettingData  = SettingData()
    
    var body: some Scene {
        WindowGroup {
            ContentView(settingsData: $settingsData)
                .modelContainer(for: UserData.self)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Elara") {
                    showAbout()
                }
            }
            
            CommandGroup(after: .windowArrangement) {
                Button("Statistics") {
                    openStatistics()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
        }
        
        
        WindowGroup(id: "stats") {
            StatisticsView()
                .modelContainer(for: UserData.self)
        }
        
        Settings {
            SettingsView(data: $settingsData)
                .modelContainer(for: UserData.self)
        }
    }
    
    private func showAbout() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        aboutWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func openStatistics() {
        openWindow(id: "stats")
    }
}
