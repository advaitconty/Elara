import SwiftUI

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
    @State var timerHover: Timer?
    @State var editTasks: Bool = false
    @State var currentTime: [String] = ["", ""]
    let clockUpdateTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image
                if let data = settings.backgroundImageData,
                   let uiImage = NSImage(data: data) {
                    Image(nsImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            minutes = settings.pomodoroDuration[0]
                            seconds = settings.pomodoroDuration[1]
                            updateTime()
                            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                                updateTime()
                            }
                        }
                        .transition(.opacity)
                } else {
                    Image(settings.background)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            minutes = settings.pomodoroDuration[0]
                            seconds = settings.pomodoroDuration[1]
                            updateTime()
                            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                                updateTime()
                            }
                        }
                        .transition(.opacity)
                }
                
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
                        
                        
                        HStack {
                            Text("\(minutes)")
                                .font(.custom(settings.font.clockFont, size: 100))
                                .foregroundColor(.white)
                                .offset(x: settings.font.clockFont == "London Underground LCD Clock" ? 10 : 0)
                            Text(":")
                                .font(.custom(settings.font.clockFont == "London Underground LCD Clock" ? "Share Tech Mono" : settings.font.clockFont, size: 100))
                                .foregroundColor(.white)
                                .offset(y: settings.font.clockFont == "London Underground LCD Clock" ? -10 : 0)
                            Text("\(String(format: "%02d", seconds))")
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
                                
                                if minutes != settings.pomodoroDuration[0] && seconds != settings.pomodoroDuration[1] {
                                    Button {
                                        stopTimer()
                                        minutes = 25
                                        seconds = 0
                                        cycles = 0
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
                                    timerHover?.invalidate()
                                } else {
                                    timerHover = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                                        withAnimation {
                                            showButton = false
                                        }
                                    }
                                }
                            }
                            .matchedGeometryEffect(id: "rect", in: namespace)
                    }
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
                                    .font(.custom(settings.font.clockFont == "London Underground LCD Clock" ? "Share Tech Mono" : settings.font.clockFont, size: 100))
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
                                    withAnimation  {
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
                                    timerHover?.invalidate()
                                } else {
                                    timerHover = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                                        withAnimation {
                                            showButton = false
                                        }
                                    }
                                }
                            }
                            .matchedGeometryEffect(id: "rect", in: namespace)
                        
                    }
                }
//            }
            
            }
            .onReceive(clockUpdateTimer) { _ in
                updateTime()
            }
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
        for todo in todos {
            if !todo.completed {
                displayedTodo = todo
                break
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if seconds == 0 && minutes == 0 {
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
                
            } else if seconds == 0 {
                seconds = 59
                minutes = minutes - 1
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
