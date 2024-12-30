//
//  StorageItems.swift
//  Solstice
//
//  Created by Milind Contractor on 28/12/24.
//

import Foundation

struct Todo: Identifiable, Codable {
    var id = UUID()
    var task: String
    var priority: Int
    var completed: Bool = false
}

struct SettingData: Codable {
    var background: String = "Default"
    var pomodoroDuration: [Int] = [25, 0]
    var shortBreakDuration: [Int] = [5, 0]
    var longBreakDuration: [Int] = [10, 0]
    var cyclesBeforeLongBreak: Int = 4
}

enum TimerMode {
    case normal, shortBreak, longBreak
    
    var displayText: String {
        switch self {
        case .normal:
            return "Work"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
}

struct Wallpaper: Identifiable {
    var id = UUID()
    var wallpaperName: String
    var description: String
    var tags: [String]
}

let wallpapers = [
    Wallpaper(wallpaperName: "Default", description: "The classic and default look of Solstice", tags: ["star"]),
    Wallpaper(wallpaperName: "Horizon", description: "A digital painting of the horizon, done by Alena Aenami (from Artstaion)", tags: []),
    Wallpaper(wallpaperName: "Lodge", description: "A wonderful wooden lodge, with a mountainside view, at the golden hour", tags: []),
    Wallpaper(wallpaperName: "Summer Scene", description: "An AI-generated image of the sunset (from Freepik, generated using Midjourney 5.2)", tags: ["cpu"]),
    Wallpaper(wallpaperName: "Moscow Metro", description: "A digital art piece of one of the Moscow metro stations", tags: [])
]
