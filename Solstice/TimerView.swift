import SwiftUI

struct TimerView: View {
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
    @State var timerHover: Timer?
    @State var editTasks: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                Image(settings.background)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .edgesIgnoringSafeArea(.all)
                
                // Centered Content
                VStack {
                    Spacer()
                    if showWelcomeBack {
                        Text("Welcome _back_, \(name).")
                            .transition(.opacity)
                            .font(.custom("Crimson Pro", size: 20))
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
                            .font(.custom("Crimson Pro", size: 20))
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }
                    
                    Text("\(minutes):\(String(format: "%02d", seconds))")
                        .font(.custom("Crimson Pro", size: 100))
                        .foregroundColor(.white)
                    
                    VStack {
                        Text("_Working on:_ \(displayedTodo.task)")
                            .font(.custom("Crimson Pro", size: 20))
                            .foregroundColor(.white)
                            .onTapGesture {
                                editTasks.toggle()
                            }
                            .onChange(of: editTasks) { _ in
                                refreshDisplayedTodo()
                            }
                            .popover(isPresented: $editTasks, arrowEdge: .trailing) {
                                TasksView(todos: $todos)
                            }
                    }
                    
                    if showButton {
                        Button {
                            if !isRunning {
                                startTimer()
                            } else {
                                stopTimer()
                            }
                        } label: {
                            VStack {
                                Image(systemName: isRunning ? "pause" : "play")
                                    .foregroundColor(.white)
                                Text(isRunning ? "Pause" : "Resume")
                                    .foregroundColor(.white)
                                    .font(.custom("Crimson Pro", size: 20))
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
                                timerHover?.invalidate()
                            } else {
                                timerHover = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                                    withAnimation {
                                        showButton = false
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
    
    func refreshDisplayedTodo() {
        for todo in todos {
            if !todo.completed {
                displayedTodo = todo
                break
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if seconds == 0 {
                seconds = 59
                minutes = minutes - 1
            } else if minutes == 0 && seconds == 0 {
                cycles = cycles + 1
                if currentTimerMode == .normal && cycles != settings.cyclesBeforeLongBreak {
                    currentTimerMode = .shortBreak
                    minutes = settings.shortBreakDuration[0]
                    seconds = settings.shortBreakDuration[1]
                } else if currentTimerMode == .shortBreak || currentTimerMode == .longBreak {
                    minutes = settings.pomodoroDuration[0]
                    seconds = settings.pomodoroDuration[1]
                } else if cycles == settings.cyclesBeforeLongBreak {
                    cycles = 0
                    minutes = settings.longBreakDuration[0]
                    seconds = settings.longBreakDuration[1]
                }
                stopTimer()
            } else {
                seconds = seconds - 1
            }
        }
        isRunning = true
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(todos: .constant([Todo(task: "Something", priority: 1)]), name: .constant("Advait"), settings: .constant(SettingData()))
    }
}
