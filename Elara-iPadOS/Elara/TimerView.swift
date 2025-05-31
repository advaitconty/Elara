import SwiftUI
import UserNotifications   // ← Needed for local notifications

struct TimerView: View {
    @AppStorage("clock") var clock: Bool = false
    @Namespace var namespace
    @Binding var todos: [Todo]
    @Binding var name: String
    @Binding var settings: SettingData
    @State var minutes: Int = 25
    @State var seconds: Int = 0
    @State var timer: Timer?
    @State var isRunning: Bool = false
    @State var currentTimerMode: TimerMode = .normal
    @State var cycles: Int = 0
    @State var displayedTodo: Todo = Todo(task: "", priority: 4)
    @State var showWelcomeBack: Bool = true
    @State var showButton: Bool = false
    @State var editTasks: Bool = false
    @State var currentTime: [String] = ["", ""]
    @State var showSettings: Bool = false
    @State private var endDate: Date? = nil
    let clockUpdateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if let data = settings.backgroundImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        requestNotificationPermission()

                        minutes = settings.pomodoroDuration[0]
                        seconds = settings.pomodoroDuration[1]

                        updateTime()

                        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                            updateTime()
                        }

                        resumeIfNeeded()
                    }
                    .transition(.opacity)
            } else {
                Image(settings.background)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        requestNotificationPermission()
                        minutes = settings.pomodoroDuration[0]
                        seconds = settings.pomodoroDuration[1]
                        updateTime()
                        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                            updateTime()
                        }
                        resumeIfNeeded()
                    }
                    .transition(.opacity)
            }

            if !clock {
                VStack {
                    Spacer()

                    // “Welcome back” or current‐mode text
                    if showWelcomeBack {
                        Text("Welcome _back_, \(name).")
                            .transition(.opacity)
                            .font(.custom(settings.font.bodyFont, size: 20))
                            .foregroundColor(.white)
                            .onAppear {
                                refreshDisplayedTodo()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation { showWelcomeBack = false }
                                }
                            }
                    } else {
                        Text(currentTimerMode.displayText)
                            .font(.custom(settings.font.bodyFont, size: 20))
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }

                    HStack {
                        Text("\(minutes)")
                            .font(.custom(settings.font.clockFont, size: 100))
                            .foregroundColor(.white)
                            .offset(x: settings.font.clockFont == "London Underground LCD Clock" ? 10 : 0)

                        Text(":")
                            .font(.custom(
                                settings.font.clockFont == "London Underground LCD Clock"
                                    ? "Share Tech Mono"
                                    : settings.font.clockFont,
                                size: 100
                            ))
                            .foregroundColor(.white)
                            .offset(y: settings.font.clockFont == "London Underground LCD Clock" ? -10 : 0)

                        Text(String(format: "%02d", seconds))
                            .font(.custom(settings.font.clockFont, size: 100))
                            .foregroundColor(.white)
                    }
                    .padding(settings.font.clockFont == "London Underground LCD Clock" ? 5 : 0)
                    .matchedGeometryEffect(id: "timer", in: namespace)

                    VStack {
                        Text("_Working on:_ \(displayedTodo.task)")
                            .font(.custom(settings.font.bodyFont, size: 20))
                            .foregroundColor(.white)
                            .onTapGesture { editTasks.toggle() }
                            .onChange(of: editTasks) { _ in
                                refreshDisplayedTodo()
                            }
                            .popover(isPresented: $editTasks, arrowEdge: .trailing) {
                                TasksView(todos: $todos, settings: $settings)
                            }
                    }
                    .transition(.opacity)

                    HStack {
                        if showButton {
                            Button {
                                if !isRunning {
                                    startTimer()
                                } else {
                                    stopTimer()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: isRunning ? "pause" : "play")
                                        .foregroundColor(.white)
                                    Text(isRunning ? "Pause" : "Resume")
                                        .foregroundColor(.white)
                                        .font(.custom(settings.font.bodyFont, size: 20))
                                }
                                .padding(5)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.5))
                                        .shadow(radius: 3)
                                )
                            }
                            .buttonStyle(.borderless)
                            .transition(.opacity)

                            if minutes != settings.pomodoroDuration[0]
                                || seconds != settings.pomodoroDuration[1]
                            {
                                Button {
                                    cancelPendingNotification()
                                    stopTimer()
                                    minutes = settings.pomodoroDuration[0]
                                    seconds = settings.pomodoroDuration[1]
                                    cycles = 0
                                    currentTimerMode = .normal
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(.white)
                                        Text("Reset")
                                            .foregroundColor(.white)
                                            .font(.custom(settings.font.bodyFont, size: 20))
                                    }
                                    .padding(5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.gray.opacity(0.5))
                                            .shadow(radius: 3)
                                    )
                                }
                                .buttonStyle(.borderless)
                                .transition(.opacity)
                            }

                            Button {
                                withAnimation { clock.toggle() }
                            } label: {
                                HStack {
                                    Image(systemName: clock ? "clock.fill" : "clock")
                                        .foregroundColor(.white)
                                }
                                .padding(9)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.5))
                                        .shadow(radius: 3)
                                )
                            }
                            .buttonStyle(.borderless)
                            .transition(.opacity)
                            .matchedGeometryEffect(id: "clock", in: namespace)

                            Button {
                                showSettings = true
                            } label: {
                                HStack {
                                    Image(systemName: "gearshape.2")
                                        .foregroundColor(.white)
                                }
                                .padding(9)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.5))
                                        .shadow(radius: 3)
                                )
                            }
                            .matchedGeometryEffect(id: "settingsBtn", in: namespace)
                            .sheet(isPresented: $showSettings) {
                                SettingsView(data: $settings)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
                .frame(minWidth: 300, maxWidth: 400, minHeight: 200, maxHeight: 300)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.7))
                        .shadow(radius: 3)
                        .onTapGesture {
                            withAnimation { showButton.toggle() }
                        }
                        .matchedGeometryEffect(id: "rect", in: namespace)
                )
                .transition(.opacity)
            }

            else {
                VStack {
                    if currentTime[0] != "" {
                        if showWelcomeBack {
                            Text("Welcome _back_, \(name).")
                                .transition(.opacity)
                                .font(.custom(settings.font.bodyFont, size: 20))
                                .foregroundColor(.white)
                                .onAppear {
                                    refreshDisplayedTodo()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation { showWelcomeBack = false }
                                    }
                                }
                        }

                        HStack {
                            Text(currentTime[0])
                                .font(.custom(settings.font.clockFont, size: 100))
                                .foregroundColor(.white)
                                .offset(x: settings.font.clockFont == "London Underground LCD Clock" ? 10 : 0)

                            Text(":")
                                .font(.custom(
                                    settings.font.clockFont == "London Underground LCD Clock"
                                        ? "Share Tech Mono"
                                        : settings.font.clockFont,
                                    size: 100
                                ))
                                .foregroundColor(.white)
                                .offset(y: settings.font.clockFont == "London Underground LCD Clock" ? -10 : 0)

                            Text(currentTime[1])
                                .font(.custom(settings.font.clockFont, size: 100))
                                .foregroundColor(.white)
                        }
                        .padding(settings.font.clockFont == "London Underground LCD Clock" ? 5 : 0)
                        .matchedGeometryEffect(id: "timer", in: namespace)
                    } else {
                        ProgressView()
                    }

                    HStack {
                        if showButton {
                            Button {
                                withAnimation { clock.toggle() }
                            } label: {
                                HStack {
                                    Image(systemName: clock ? "clock.fill" : "clock")
                                        .foregroundColor(.white)
                                }
                                .padding(9)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.5))
                                        .shadow(radius: 3)
                                )
                            }
                            .buttonStyle(.borderless)
                            .matchedGeometryEffect(id: "clock", in: namespace)

                            Button {
                                showSettings = true
                            } label: {
                                HStack {
                                    Image(systemName: "gearshape.2")
                                        .foregroundColor(.white)
                                }
                                .padding(9)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.gray.opacity(0.5))
                                        .shadow(radius: 3)
                                )
                            }
                            .matchedGeometryEffect(id: "settingsBtn", in: namespace)
                            .sheet(isPresented: $showSettings) {
                                SettingsView(data: $settings)
                            }
                        }
                    }
                }
                .padding()
                .frame(minWidth: 300, maxWidth: 400, minHeight: 200, maxHeight: 300)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.7))
                        .shadow(radius: 3)
                        .onTapGesture {
                            withAnimation { showButton.toggle() }
                        }
                        .matchedGeometryEffect(id: "rect", in: namespace)
                )
                .transition(.opacity)
            }
        }
        .onReceive(clockUpdateTimer) { _ in
            updateTime()
        }
    }

    func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        currentTime[0] = formatter.string(from: Date())
        formatter.dateFormat = "mm"
        currentTime[1] = formatter.string(from: Date())
    }

    func refreshDisplayedTodo() {
        for todo in todos where !todo.completed {
            displayedTodo = todo
            break
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }

    func resumeIfNeeded() {
        guard isRunning, let end = endDate else { return }
        let remaining = Int(end.timeIntervalSinceNow)
        if remaining > 0 {
            minutes = remaining / 60
            seconds = remaining % 60
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateRemainingTime()
            }
        } else {
            minutes = 0
            seconds = 0
            stopTimer()
            handleTimerCompletion()
        }
    }

    func startTimer() {
        let totalSeconds = minutes * 60 + seconds

        endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateRemainingTime()
        }
        isRunning = true

        scheduleTimerNotification(in: totalSeconds)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        endDate = nil

        cancelPendingNotification()
    }

    func updateRemainingTime() {
        guard let end = endDate else { return }
        let remaining = Int(end.timeIntervalSinceNow)

        if remaining <= 0 {
            // Time’s up
            minutes = 0
            seconds = 0
            stopTimer()
            handleTimerCompletion()
        } else {
            minutes = remaining / 60
            seconds = remaining % 60
        }
    }

    func handleTimerCompletion() {
        cycles += 1

        if currentTimerMode == .normal && cycles != settings.cyclesBeforeLongBreak {
            currentTimerMode = .shortBreak
            minutes = settings.shortBreakDuration[0]
            seconds = settings.shortBreakDuration[1]
        } else if currentTimerMode == .shortBreak || currentTimerMode == .longBreak {
            currentTimerMode = .normal
            minutes = settings.pomodoroDuration[0]
            seconds = settings.pomodoroDuration[1]
        } else if cycles == settings.cyclesBeforeLongBreak {
            cycles = 0
            currentTimerMode = .longBreak
            minutes = settings.longBreakDuration[0]
            seconds = settings.longBreakDuration[1]
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func scheduleTimerNotification(in seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Times up!"
        content.body = "\(currentTimerMode.displayText) is over!"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(seconds),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "TimerComplete",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelPendingNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["TimerComplete"])
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(
            todos: .constant([Todo(task: "Something", priority: 1)]),
            name: .constant("Advait"),
            settings: .constant(SettingData())
        )
    }
}
