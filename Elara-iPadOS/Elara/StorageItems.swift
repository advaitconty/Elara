import Foundation

struct Cycle: Identifiable, Codable {
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

struct ClockFont: Codable {
    var titleFont: String = "Playfair Display"
    var bodyFont: String = "Crimson Pro"
    var clockFont: String = "Crimson Pro"
}

struct SettingData: Codable {
    var background: String = "Default"
    var backgroundImageData: Data? = nil
    var pomodoroDuration: [Int] = [25, 0]
    var shortBreakDuration: [Int] = [5, 0]
    var longBreakDuration: [Int] = [10, 0]
    var cyclesBeforeLongBreak: Int = 4
    var font: ClockFont = ClockFont()
    var notificationsPermissionsGiven: Bool = false
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
    
    
    
//    mutating func recalculate() {
//        let timeInterval = self.timerEndTime.timeIntervalSinceNow
//        self.remainingMinutes = Int(timeInterval / 60)
//        self.remainingSeconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
//        self.formattedTime = String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
//    }
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
    Wallpaper(wallpaperName: "Moscow Metro", description: "A digital art piece of one of the Moscow metro stations", tags: [])
]
