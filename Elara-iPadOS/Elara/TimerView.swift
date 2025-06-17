import SwiftUI
import UserNotifications

struct TimerView: View {
    @AppStorage("clock") var clock: Bool = false
    @Environment(\.scenePhase) var scenePhase
    @Namespace var namespace
    @Binding var todos: [Todo]
    @Binding var name: String
    @Binding var settings: SettingData
    @State var displayedTodo: Todo = Todo(task: "", priority: 4)
    @State var showWelcomeBack: Bool = true
    @State var showButton: Bool = false
    @State var editTasks: Bool = false
    @State var mouseConnected: Bool = false
    @State var showSettings: Bool = false
    @StateObject var pomodoroTimer: PomodoroTimer = PomodoroTimer()
    @State var refreshTrigger: Int = 0
    @State var clockTimer: ClockMode = ClockMode()
    @State var recalcuatingDateInPause: Bool = false
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    @State var loading = true
    @State var shownTime: String = "25:00"
    
    func pause() {
        pomodoroTimer.isRunning = false
        pomodoroTimer.timePassedInSeconds = pomodoroTimer.remainingMinutes * 60 + pomodoroTimer.remainingSeconds + 1
    }
    
    func resume() {
        pomodoroTimer.isRunning = true
        pomodoroTimer.timePassedInSeconds = nil
    }
    
    func refreshDisplayedTodo() {
        for todo in todos where !todo.completed {
            displayedTodo = todo
            break
        }
    }
    
    var body: some View {
        ZStack {
            if let data = settings.backgroundImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            } else {
                Image(settings.background)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
            
            if !clock {
                // ───────────────────────────────────────────────────────────
                //                          TIMER MODE
                // ───────────────────────────────────────────────────────────
                VStack {
                    Spacer()
                        .onChange(of: pomodoroTimer.formattedTime) {
                            if pomodoroTimer.formattedTime == "00:00" {
                                pomodoroTimer.isRunning = false
                                if pomodoroTimer.timerMode == .normal {
                                    pomodoroTimer.cycles += 1
                                }
                                if pomodoroTimer.cycles == settings.cyclesBeforeLongBreak {
                                    pomodoroTimer.timerMode = .longBreak
                                    pomodoroTimer.cycles = 0
                                } else if pomodoroTimer.timerMode == .normal {
                                    pomodoroTimer.timerMode = .shortBreak
                                } else if pomodoroTimer.timerMode == .shortBreak {
                                    pomodoroTimer.timerMode = .normal
                                }
                            }
                        }
                        .onReceive(timer) { _ in
                            if !pomodoroTimer.isRunning {
                                if let timePassedInSeconds = pomodoroTimer.timePassedInSeconds {
                                    pomodoroTimer.timerEndTime = Date().addingTimeInterval(TimeInterval(timePassedInSeconds))
                                } else {
                                    switch pomodoroTimer.timerMode {
                                    case .normal:
                                        pomodoroTimer.timerEndTime = Date().addingTimeInterval(TimeInterval(settings.pomodoroDuration[0] * 60 + settings.pomodoroDuration[1] + 1))
                                    case .shortBreak:
                                        pomodoroTimer.timerEndTime = Date().addingTimeInterval(TimeInterval(settings.shortBreakDuration[0] * 60 + settings.shortBreakDuration[1] + 1))
                                    case .longBreak:
                                        pomodoroTimer.timerEndTime = Date().addingTimeInterval(TimeInterval(settings.longBreakDuration[0] * 60 + settings.longBreakDuration[1] + 1))
                                    }
                                }
                            } else if pomodoroTimer.isRunning {
                                pomodoroTimer.invokeRefresh.toggle()
                            }
                            shownTime = pomodoroTimer.formattedTime
                        }
                        .onAppear {
                            pomodoroTimer.cycles = settings.cyclesBeforeLongBreak
                            pomodoroTimer.timerEndTime = Date().addingTimeInterval(TimeInterval(settings.pomodoroDuration[0] * 60 + settings.pomodoroDuration[1] + 1))
                            refreshDisplayedTodo()
                            shownTime = String(format: "%02d:%02d", settings.pomodoroDuration[0], settings.pomodoroDuration[1])
                        }
                        .onChange(of: editTasks) {
                            refreshDisplayedTodo()
                        }
                    
                    // greetings my good sir
                    if showWelcomeBack {
                        Text("Welcome _back_, \(name).")
                            .transition(.opacity)
                            .font(.custom(settings.font.bodyFont, size: 20))
                            .foregroundColor(.white)
                    } else {
                        Text(pomodoroTimer.timerMode.displayText)
                            .font(.custom(settings.font.bodyFont, size: 20))
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }
                    
                    if loading {
                        VStack {
                            Spacer()
                            Text(shownTime)
                                .font(.custom(settings.font.clockFont, size: 100))
                                .foregroundColor(.white)
                                .monospacedDigit()
                            Spacer()
                        }
                        .matchedGeometryEffect(id: "timer", in: namespace)
                    } else {
                        VStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                    
                    // your work to lock in
                    Text("_Working on:_ \(displayedTodo.task)")
                        .font(.custom(settings.font.bodyFont, size: 20))
                        .foregroundColor(.white)
                        .onTapGesture { editTasks.toggle() }
                        .onChange(of: editTasks) {
                            refreshDisplayedTodo()
                        }
                        .popover(isPresented: $editTasks, arrowEdge: .trailing) {
                            TasksView(todos: $todos, settings: $settings)
                        }
                        .padding(.top, 8)
                        .transition(.opacity)
                    
                    // timer button + stuff
                    if showButton {
                        HStack {
                        // start/stop
                            Button {
                                if pomodoroTimer.isRunning {
                                    pause()
                                } else {
                                    resume()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: pomodoroTimer.isRunning ? "pause" : "play")
                                        .foregroundColor(.white)
                                    Text(pomodoroTimer.isRunning ? "Pause" : "Resume")
                                        .foregroundColor(.white)
                                        .font(.custom(settings.font.bodyFont, size: 20))
                                }
                            }
                            .buttonStyle(.bordered)
                            .transition(.opacity)
                            .hoverEffect(.automatic)

                            
                            // reset
                            if pomodoroTimer.formattedTime != "\(settings.pomodoroDuration[0]):\(settings.pomodoroDuration[1])" {
                                Button {
                                    pomodoroTimer.isRunning = false
                                    pomodoroTimer.timerMode = .shortBreak
                                    pomodoroTimer.cycles = 0
                                    shownTime = String(format: "%02d:%02d", settings.pomodoroDuration[0], settings.pomodoroDuration[1])
                                    pomodoroTimer.timerEndTime = Date()
                                    pomodoroTimer.timePassedInSeconds = nil
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(.white)
                                        Text("Reset")
                                            .foregroundColor(.white)
                                            .font(.custom(settings.font.bodyFont, size: 20))
                                    }
                                }
                                .buttonStyle(.bordered)
                                .transition(.opacity)
                                .hoverEffect(.automatic)
                            }
                            
                            // clock mode
                            Button {
                                withAnimation { clock.toggle() }
                            } label: {
                                HStack {
                                    Image(systemName: clock ? "clock.fill" : "clock")
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.bordered)
                            .transition(.opacity)
                            .matchedGeometryEffect(id: "clock", in: namespace)
                            .hoverEffect(.automatic)
                            
                            // settings
                            Button {
                                showSettings = true
                            } label: {
                                HStack {
                                    Image(systemName: "gearshape.2")
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.bordered)
                            .matchedGeometryEffect(id: "settingsBtn", in: namespace)
                            .sheet(isPresented: $showSettings) {
                                SettingsView(data: $settings)
                            }
                            .hoverEffect(.automatic)
                        }
                        .padding(.top, 8)
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
                
            } else {
                // ───────────────────────────────────────────────────────────
                //                     CLOCK MODE UI (HH:mm)
                // ───────────────────────────────────────────────────────────
                VStack {
                    if !clockTimer.formattedTimeShort.isEmpty {
                        VStack(spacing: 20) {
                            if showWelcomeBack {
                                Text("Welcome *back*, \(name).")
                                    .transition(.opacity)
                                    .font(.custom(settings.font.bodyFont, size: 20))
                                    .foregroundColor(.white)
                                    .onAppear {
                                        // refreshDisplayedTodo()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                showWelcomeBack = false
                                            }
                                        }
                                    }
                            }
                            
                            HStack {
                                VStack {
                                    Spacer()
                                    Text(clockTimer.formattedTimeShort)
                                        .font(.custom(settings.font.clockFont, size: 100))
                                        .foregroundColor(.white)
                                        .monospacedDigit()
                                    Spacer()
                                }
                                .matchedGeometryEffect(id: "timer", in: namespace)
                            }
                            .padding(settings.font.clockFont == "London Underground LCD Clock" ? 5 : 0)
                            .matchedGeometryEffect(id: "timer", in: namespace)
                        }
                        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                            refreshTrigger += 1
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
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
                            }
                            .buttonStyle(.bordered)
                            .matchedGeometryEffect(id: "clock", in: namespace)
                            .hoverEffect(.automatic)
                            
                            // ⚙︎ Open Settings
                            Button {
                                showSettings = true
                            } label: {
                                HStack {
                                    Image(systemName: "gearshape.2")
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.bordered)
                            .matchedGeometryEffect(id: "settingsBtn", in: namespace)
                            .sheet(isPresented: $showSettings) {
                                SettingsView(data: $settings)
                            }
                            .hoverEffect(.automatic)
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
