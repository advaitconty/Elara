import Foundation
import UserNotifications
import FamilyControls
import SwiftData

struct Cycle: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var timeSpentOnWorkCycle: Int // in seconds
    var timeSpentOnBreakCycle: Int // in seconds
    var date: Date = Date()
    var workingOnTask: Todo
}

struct Todo: Identifiable, Codable, Equatable {
    var id = UUID()
    var task: String
    var priority: Int
    var completed: Bool = false
    var showDeletePopup: Bool = false
}

struct ClockFont: Codable, Equatable {
    var titleFont: String = "Playfair Display"
    var bodyFont: String = "Crimson Pro"
    var clockFont: String = "Crimson Pro"
}

struct SettingData: Codable, Equatable {
    var background: String = "Default"
    var backgroundImageData: Data? = nil
    var pomodoroDuration: [Int] = [25, 0]
    var shortBreakDuration: [Int] = [5, 0]
    var longBreakDuration: [Int] = [10, 0]
    var cyclesBeforeLongBreak: Int = 4
    var font: ClockFont = ClockFont()
    var notificationsPermissionsGiven: Bool = false
    var notificationSound: NotificationSound = sounds.first(where: { $0.friendlyName.contains("Serenity (Default)") }) ?? sounds[0]
    var allowedScreenTimeManagementAccess: Bool = false
    var appsBlocked: FamilyActivitySelection = FamilyActivitySelection()
    var blockingInProgress: Bool = false
    var turnAppBlockingOffOnPause: Bool = true
}

struct SortedDataByTasks: Identifiable {
    var id: UUID = UUID()
    var task: String
    var timeSpentOnTask: Int
}


struct SortedDataByDate: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var timeSpentOnTask: Int
    
    var displayFriendlyDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self.date)
    }
}

enum TimerMode: Codable {
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
    
    
    var displaySymbol: String {
        switch self {
        case .normal:
            return "book"
        case .shortBreak:
            return "cup.and.saucer"
        case .longBreak:
            return "zzz"
        }
    }
}

class PomodoroTimer: ObservableObject {
    @Published var timerMode: TimerMode = .normal
    @Published var isRunning: Bool = false
    @Published var timerEndTime: Date = Date()
    var remainingMinutes: Int {
        let timeInterval = self.timerEndTime.timeIntervalSinceNow
        return Int(timeInterval / 60)
    }
    var remainingSeconds: Int {
        let timeInterval = self.timerEndTime.timeIntervalSinceNow
        return Int(timeInterval.truncatingRemainder(dividingBy: 60))
    }
    @Published var timePassedInSeconds: Int?
    @Published var cycles: Int = 4
    @Published var invokeRefresh: Bool = false
    var formattedTime: String {
        return String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
    }
}


// clock mode formatter
struct ClockMode: Codable, Equatable {
    var formattedTimeShort: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: now)
    }
}


struct Wallpaper: Identifiable {
    var id = UUID()
    var wallpaperName: String
    var description: String
    var tags: [String]
}

let wallpapers = [
    Wallpaper(wallpaperName: "Default", description: "The classic and default look of Elara", tags: ["star"]),
    Wallpaper(wallpaperName: "Horizon", description: "A digital painting of the horizon, done by Alena Aenami (from Artstaion)", tags: []),
    Wallpaper(wallpaperName: "Lodge", description: "A wonderful wooden lodge, with a mountainside view, at the golden hour", tags: []),
    Wallpaper(wallpaperName: "Summer Scene", description: "An AI-generated image of the sunset (from Freepik, generated using Midjourney 5.2)", tags: ["cpu"]),
    Wallpaper(wallpaperName: "Moscow Metro", description: "A digital art piece of one of the Moscow metro stations", tags: []),
    Wallpaper(wallpaperName: "Cloud Nine", description: "A weightless escape into the bliss of work and achievement.", tags: []),
    Wallpaper(wallpaperName: "Nocturne Sands", description: "Inviting focus through stillness, in the silence of the clear night.", tags: []),
    Wallpaper(wallpaperName: "Roselight", description: "Gentle, rare and full of wonder, an inspiration to your productivity.", tags: []),
    Wallpaper(wallpaperName: "Serene Ascent", description: "The calm strength, where focus is found in the climb to success.", tags: []),
    Wallpaper(wallpaperName: "Silent Pines", description: "A gentle retreat into quiet - grounded, muted and possibly peaceful", tags: [])
]

struct NotificationSound: Identifiable, Codable, Hashable {
    var id = UUID()
    var fileName: String
    var friendlyName: String
    
    func getUNNotificationSoundName() -> UNNotificationSound {
        return UNNotificationSound(named: UNNotificationSoundName(fileName))
    }
}

let sounds = [
    NotificationSound(fileName: "Sci-Fi.wav", friendlyName: "Nebula"),
    NotificationSound(fileName: "Ringer.wav", friendlyName: "Dialback"),
    NotificationSound(fileName: "Fantasy.wav", friendlyName: "Lumos"),
    NotificationSound(fileName: "Relaxing.wav", friendlyName: "Serenity (Default)")
]

@Model
class UserData {
    var settingsData: SettingData = SettingData()
    var todos: [Todo] = []
    var cycles: [Cycle] = []
    var name: String = ""
    var setupPage: Int = 1
    
    init(settingsData: SettingData, todos: [Todo], cycles: [Cycle], name: String, setupPage: Int) {
        self.settingsData = settingsData
        self.todos = todos
        self.cycles = cycles
        self.name = name
        self.setupPage = setupPage
    }
}
