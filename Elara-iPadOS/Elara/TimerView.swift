import SwiftUI
import UserNotifications

struct TimerView: View {
    // MARK: – AppStorage / Namespace / Bindings
    @AppStorage("clock") var clock: Bool = false
    @Namespace var namespace

    @Binding var todos: [Todo]
    @Binding var name: String
    @Binding var settings: SettingData

    // MARK: – Countdown State
    // Use a single `remainingSeconds` value rather than separate minutes & seconds
    @State private var remainingSeconds: Int = 0
    @State private var countdownTimer: Timer? = nil
    @State private var isRunning: Bool = false
    @State private var currentTimerMode: TimerMode = .normal
    @State private var cycles: Int = 0

    // Derived computed properties for display
    private var displayMinutes: Int {
        max(0, remainingSeconds / 60)
    }
    private var displaySeconds: Int {
        max(0, remainingSeconds % 60)
    }

    // MARK: – “Working on” & UI State
    @State private var displayedTodo: Todo = Todo(task: "", priority: 4)
    @State private var showWelcomeBack: Bool = true
    @State private var showButton: Bool = false
    @State private var editTasks: Bool = false

    // MARK: – Clock Mode State
    @State private var currentTime: [String] = ["", ""]
    let clockUpdateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: – Settings Sheet
    @State private var showSettings: Bool = false

    // MARK: – For resuming if backgrounded
    @State private var endDate: Date? = nil

    var body: some View {
        ZStack {
            // MARK: – Background (Image or default color)
            if let data = settings.backgroundImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        self.configureOnAppear()
                    }
                    .transition(.opacity)
            } else {
                Image(settings.background)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        self.configureOnAppear()
                    }
                    .transition(.opacity)
            }

            // MARK: – Main Content: Timer Mode vs Clock Mode
            if !clock {
                // ───────────────────────────────────────────────────────────
                //                            TIMER MODE
                // ───────────────────────────────────────────────────────────
                VStack {
                    Spacer()

                    // “Welcome back” or current‐mode text
                    if showWelcomeBack {
                        Text("Welcome _back_, \(name).")
                            .transition(.opacity)
                            .font(.custom(settings.font.bodyFont, size: 20))
                            .foregroundColor(.white)
                            .onAppear {
                                self.refreshDisplayedTodo()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation { self.showWelcomeBack = false }
                                }
                            }
                    } else {
                        Text(currentTimerMode.displayText)
                            .font(.custom(settings.font.bodyFont, size: 20))
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }

                    // Countdown Display: MM:SS
                    HStack {
                        Text("\(displayMinutes)")
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

                        Text(String(format: "%02d", displaySeconds))
                            .font(.custom(settings.font.clockFont, size: 100))
                            .foregroundColor(.white)
                    }
                    .padding(settings.font.clockFont == "London Underground LCD Clock" ? 5 : 0)
                    .matchedGeometryEffect(id: "timer", in: namespace)

                    // “Working on: <task>”
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
                        .padding(.top, 8)
                        .transition(.opacity)

                    // Play/Pause / Reset / Clock / Settings buttons
                    HStack {
                        if showButton {
                            // ▶︎ Resume / ❚❚ Pause
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

                            // ↻ Reset (only if we've moved away from the original duration)
                            if remainingSeconds != settings.pomodoroDuration[0] * 60 + settings.pomodoroDuration[1] {
                                Button {
                                    cancelPendingNotification()
                                    stopTimer()
                                    resetToPomodoro()
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

                            // ⏰ Toggle Clock Mode
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

                            // ⚙︎ Open Settings
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
                    .padding(.top, 8)

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

            } else {
                // ───────────────────────────────────────────────────────────
                //                           CLOCK MODE (HH:mm)
                // ───────────────────────────────────────────────────────────
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
                            // ⏱ Toggle back to timer
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

                            // ⚙︎ Open Settings
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
        // ───────────────────────────────────────────────────────────────
        //                               ON RECEIVE CLOCK TIMER
        // ───────────────────────────────────────────────────────────────
        .onReceive(clockUpdateTimer) { _ in
            updateTime()
        }
    }

    // MARK: – Helper to initialize state onAppear
    private func configureOnAppear() {
        requestNotificationPermission()
        resetToPomodoro()
        updateTime() // for clock mode

        // Every minute, keep updating currentTime
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            updateTime()
        }

        resumeIfNeeded()
    }

    // MARK: – Convert settings.pomodoroDuration ([mins, secs]) to total seconds
    private func resetToPomodoro() {
        let pomodoroMins = settings.pomodoroDuration[0]
        let pomodoroSecs = settings.pomodoroDuration[1]
        remainingSeconds = pomodoroMins * 60 + pomodoroSecs
        currentTimerMode = .normal
        cycles = 0
    }

    // MARK: – Update “HH:mm” for clock mode
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        currentTime[0] = formatter.string(from: Date())
        formatter.dateFormat = "mm"
        currentTime[1] = formatter.string(from: Date())
    }

    // MARK: – Pick the next unfinished todo
    private func refreshDisplayedTodo() {
        for todo in todos where !todo.completed {
            displayedTodo = todo
            break
        }
    }

    // MARK: – Ask for Notification permission once
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Notification permission error:", error.localizedDescription)
            } else {
                print("Notification permission granted? \(granted)")
            }
        }
    }

    // MARK: – If user backgrounds & returns, pick up where we left off
    private func resumeIfNeeded() {
        guard isRunning, let end = endDate else { return }
        let now = Date()
        let delta = Int(end.timeIntervalSince(now))
        if delta > 0 {
            remainingSeconds = delta
            startCountdownTimer()
        } else {
            remainingSeconds = 0
            stopTimer()
            handleTimerCompletion()
        }
    }

    // MARK: – Start the countdown Timer
    private func startTimer() {
        // 1) Compute total seconds (already stored in remainingSeconds)
        let total = remainingSeconds

        // 2) Record the end time so we can resume if backgrounded
        endDate = Date().addingTimeInterval(TimeInterval(total))

        // 3) Kick off the 1-second Timer
        startCountdownTimer()

        isRunning = true

        // 4) Schedule local notification for when the timer ends
        scheduleTimerNotification(in: total)
    }

    private func startCountdownTimer() {
        // If a timer already exists, invalidate it first
        countdownTimer?.invalidate()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            tickCountdown()
        }
    }

    // MARK: – Each 1-second tick
    private func tickCountdown() {
        guard remainingSeconds > 0 else {
            // Time’s up
            remainingSeconds = 0
            stopTimer()
            handleTimerCompletion()
            return
        }

        remainingSeconds -= 1 // decrement exactly once per tick
    }

    // MARK: – Stop the countdown
    private func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        isRunning = false
        endDate = nil

        cancelPendingNotification()
    }

    // MARK: – After one Pomodoro / break finishes, switch modes
    private func handleTimerCompletion() {
        cycles += 1

        if currentTimerMode == .normal && cycles != settings.cyclesBeforeLongBreak {
            // Switch to short break
            currentTimerMode = .shortBreak
            let sbM = settings.shortBreakDuration[0]
            let sbS = settings.shortBreakDuration[1]
            remainingSeconds = sbM * 60 + sbS
        } else if currentTimerMode == .shortBreak || currentTimerMode == .longBreak {
            // Switch back to normal Pomodoro
            currentTimerMode = .normal
            let pM = settings.pomodoroDuration[0]
            let pS = settings.pomodoroDuration[1]
            remainingSeconds = pM * 60 + pS
        } else if cycles == settings.cyclesBeforeLongBreak {
            // Time for a long break
            cycles = 0
            currentTimerMode = .longBreak
            let lbM = settings.longBreakDuration[0]
            let lbS = settings.longBreakDuration[1]
            remainingSeconds = lbM * 60 + lbS
        }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Optionally: automatically start the next session by calling startTimer() here
    }

    // MARK: – Local Notification scheduling
    private func scheduleTimerNotification(in seconds: Int) {
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
                print("Error scheduling notification:", error.localizedDescription)
            }
        }
    }

    private func cancelPendingNotification() {
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
