import SwiftUI
import UserNotifications
import Combine

struct TimerView: View {
    @AppStorage("clock") var clock: Bool = false
    @Namespace var namespace
    @Binding var todos: [Todo]
    @Binding var name: String
    @Binding var settings: SettingData
    @State private var remainingSeconds: Int = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var isRunning: Bool = false
    @State private var currentTimerMode: TimerMode = .normal
    @State private var cycles: Int = 0
    @State private var displayedTodo: Todo = Todo(task: "", priority: 4)
    @State private var showWelcomeBack: Bool = true
    @State private var showButton: Bool = false
    @State private var timerHover: AnyCancellable?
    @State private var editTasks: Bool = false

    @State private var currentTime: [String] = ["", ""]
    let clockUpdateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private func initializeDuration() {
        let minutes = settings.pomodoroDuration[0]
        let seconds = settings.pomodoroDuration[1]
        remainingSeconds = minutes * 60 + seconds
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let data = settings.backgroundImageData,
                   let uiImage = NSImage(data: data) {
                    Image(nsImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            requestNotificationsPermission()
                            initializeDuration()
                        }
                        .transition(.opacity)
                } else {
                    Image(settings.background)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            requestNotificationsPermission()
                            initializeDuration()
                        }
                        .transition(.opacity)
                }

                VStack {
                    if !clock {
                        VStack {
                            Spacer()

                            if showWelcomeBack {
                                Text("Welcome _back_, \(name).")
                                    .transition(.opacity)
                                    .font(.custom(settings.font.bodyFont, size: 20))
                                    .foregroundColor(.white)
                                    .onAppear {
                                        refreshDisplayedTodo()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation {
                                                showWelcomeBack = false
                                            }
                                        }
                                    }
                            } else {
                                Text(currentTimerMode.displayText)
                                    .font(.custom(settings.font.bodyFont, size: 20))
                                    .foregroundColor(.white)
                                    .transition(.opacity)
                            }

                            let mins = remainingSeconds / 60
                            let secs = remainingSeconds % 60
                            HStack {
                                Text("\(mins)")
                                    .font(.custom(settings.font.clockFont, size: 100))
                                    .foregroundColor(.white)
                                    .offset(x: settings.font.clockFont == "London Underground LCD Clock" ? 10 : 0)
                                Text(":")
                                    .font(.custom(
                                        settings.font.clockFont == "London Underground LCD Clock" ? "Share Tech Mono" : settings.font.clockFont,
                                        size: 100
                                    ))
                                    .foregroundColor(.white)
                                    .offset(y: settings.font.clockFont == "London Underground LCD Clock" ? -10 : 0)
                                Text(String(format: "%02d", secs))
                                    .font(.custom(settings.font.clockFont, size: 100))
                                    .foregroundColor(.white)
                            }
                            .padding(settings.font.clockFont == "London Underground LCD Clock" ? 5 : 0)
                            .matchedGeometryEffect(id: "timer", in: namespace)

                            VStack {
                                Text("_Working on:_ \(displayedTodo.task)")
                                    .font(.custom(settings.font.bodyFont, size: 20))
                                    .foregroundColor(.white)
                                    .onTapGesture {
                                        editTasks.toggle()
                                    }
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
                                            pauseTimer()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: isRunning ? "pause" : "play")
                                                .foregroundColor(.white)
                                            Text(isRunning ? "Pause" : "Start")
                                                .foregroundColor(.white)
                                                .font(.custom(settings.font.bodyFont, size: 20))
                                        }
                                        .padding(5)
                                        .background {
                                            RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                                .fill(Color.gray)
                                                .opacity(0.5)
                                                .blendMode(.overlay)
                                                .shadow(radius: 3)
                                        }
                                    }
                                    .buttonStyle(.borderless)
                                    .transition(.opacity)

                                    if remainingSeconds != settings.pomodoroDuration[0] * 60 + settings.pomodoroDuration[1] {
                                        Button {
                                            resetTimer()
                                        } label: {
                                            HStack {
                                                Image(systemName: "arrow.clockwise")
                                                    .foregroundColor(.white)
                                                Text("Reset")
                                                    .foregroundColor(.white)
                                                    .font(.custom(settings.font.bodyFont, size: 20))
                                            }
                                            .padding(5)
                                            .background {
                                                RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                                    .fill(Color.gray)
                                                    .opacity(0.5)
                                                    .blendMode(.overlay)
                                                    .shadow(radius: 3)
                                            }
                                        }
                                        .buttonStyle(.borderless)
                                        .transition(.opacity)
                                    }

                                    Button {
                                        withAnimation {
                                            clock.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: clock ? "clock.fill" : "clock")
                                                .foregroundColor(.white)
                                        }
                                        .padding(9)
                                        .background {
                                            RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                                .fill(Color.gray)
                                                .opacity(0.5)
                                                .blendMode(.overlay)
                                                .shadow(radius: 3)
                                        }
                                    }
                                    .buttonStyle(.borderless)
                                    .transition(.opacity)
                                    .matchedGeometryEffect(id: "clock", in: namespace)
                                }
                            }

                            Spacer()
                        }
                        .padding()
                        .frame(minWidth: 300, maxWidth: 400, minHeight: 200, maxHeight: 300)
                        .background {
                            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                                .fill(Color.black)
                                .opacity(0.7)
                                .blendMode(.overlay)
                                .shadow(radius: 3)
                                .onHover { hovering in
                                    if hovering {
                                        withAnimation {
                                            showButton = true
                                        }
                                        timerHover?.cancel()
                                    } else {
                                        timerHover = Just(())
                                            .delay(for: .seconds(3), scheduler: RunLoop.main)
                                            .sink { _ in
                                                withAnimation {
                                                    showButton = false
                                                }
                                            }
                                    }
                                }
                                .matchedGeometryEffect(id: "rect", in: namespace)
                        }
                        .transition(.opacity)
                    } else {
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
                                                withAnimation {
                                                    showWelcomeBack = false
                                                }
                                            }
                                        }
                                }

                                HStack {
                                    Text("\(currentTime[0])")
                                        .font(.custom(settings.font.clockFont, size: 100))
                                        .foregroundColor(.white)
                                        .offset(x: settings.font.clockFont == "London Underground LCD Clock" ? 10 : 0)
                                    Text(":")
                                        .font(.custom(
                                            settings.font.clockFont == "London Underground LCD Clock" ? "Share Tech Mono" : settings.font.clockFont,
                                            size: 100
                                        ))
                                        .foregroundColor(.white)
                                        .offset(y: settings.font.clockFont == "London Underground LCD Clock" ? -10 : 0)
                                    Text("\(currentTime[1])")
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
                                        withAnimation {
                                            clock.toggle()
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: clock ? "clock.fill" : "clock")
                                                .foregroundColor(.white)
                                        }
                                        .padding(9)
                                        .background {
                                            RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                                .fill(Color.gray)
                                                .opacity(0.5)
                                                .blendMode(.overlay)
                                                .shadow(radius: 3)
                                        }
                                    }
                                    .buttonStyle(.borderless)
                                    .matchedGeometryEffect(id: "clock", in: namespace)
                                }
                            }
                        }
                        .padding()
                        .frame(minWidth: 300, maxWidth: 400, minHeight: 200, maxHeight: 300)
                        .background {
                            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                                .fill(Color.black)
                                .opacity(0.7)
                                .blendMode(.overlay)
                                .shadow(radius: 3)
                                .onHover { hovering in
                                    if hovering {
                                        withAnimation {
                                            showButton = true
                                        }
                                        timerHover?.cancel()
                                    } else {
                                        timerHover = Just(())
                                            .delay(for: .seconds(3), scheduler: RunLoop.main)
                                            .sink { _ in
                                                withAnimation {
                                                    showButton = false
                                                }
                                            }
                                    }
                                }
                                .matchedGeometryEffect(id: "rect", in: namespace)
                        }
                    }
                }
                .onReceive(clockUpdateTimer) { _ in
                    updateTime()
                }
                .onAppear {
                    updateTime()
                }
            }
        }
    }

    // MARK: – Timer Functions

    private func startTimer() {
        guard !isRunning else { return }

        if remainingSeconds == 0 {
            initializeDuration()
        }

        isRunning = true

        timerCancellable = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                tick()
            }
    }

    private func pauseTimer() {
        guard isRunning else { return }
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func resetTimer() {
        pauseTimer()
        cycles = 0
        currentTimerMode = .normal
        initializeDuration()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TimerComplete"])
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            // Timer has reached zero
            timerCancellable?.cancel()
            timerCancellable = nil
            isRunning = false
            handleTimerCompletion()
            return
        }
        remainingSeconds -= 1
    }

    private func handleTimerCompletion() {
        scheduleImmediateNotification()

        cycles += 1
        if currentTimerMode == .normal && cycles != settings.cyclesBeforeLongBreak {
            currentTimerMode = .shortBreak
            remainingSeconds = settings.shortBreakDuration[0] * 60 + settings.shortBreakDuration[1]
        } else if currentTimerMode == .shortBreak || currentTimerMode == .longBreak {
            currentTimerMode = .normal
            remainingSeconds = settings.pomodoroDuration[0] * 60 + settings.pomodoroDuration[1]
        } else if cycles == settings.cyclesBeforeLongBreak {
            cycles = 0
            currentTimerMode = .longBreak
            remainingSeconds = settings.longBreakDuration[0] * 60 + settings.longBreakDuration[1]
        }
    }

    private func scheduleImmediateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Times up!"
        content.body = "\(currentTimerMode.displayText) is over!"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "TimerComplete", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ [TimerView] Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ [TimerView] Scheduled 'TimerComplete' notification")
            }
        }
    }

    private func resumeIfNeeded() {
        guard !isRunning && remainingSeconds > 0 else { return }
        startTimer()
    }


    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        currentTime[0] = formatter.string(from: Date())
        formatter.dateFormat = "mm"
        currentTime[1] = formatter.string(from: Date())
    }

    private func refreshDisplayedTodo() {
        for todo in todos where !todo.completed {
            displayedTodo = todo
            break
        }
    }

    private func requestNotificationsPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted? \(granted)")
            }
        }
    }
}
