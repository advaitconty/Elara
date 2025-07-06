import SwiftUI
import SwiftData

// MARK: Font Lists
let availableClockFonts = ["Playfair Display",
                           "London Underground LCD Clock",
                           "Crimson Pro",
                           "Chakra Petch",
                           "Share Tech Mono",
                           "Helvetica Neue",
                           "Avenir Next",
                           "Doto",
                           "Space Grotesk",
                           "Playwrite AU SA",
                           "Public Sans"]

let availableFonts = ["Playfair Display",
                      "Crimson Pro",
                      "Chakra Petch",
                      "Share Tech Mono",
                      "Helvetica Neue",
                      "Avenir Next",
                      "Space Grotesk",
                      "Playwrite Australia SA",
                      "Public Sans"]

// MARK: SettingsView
struct SettingsView: View {
    @Binding var data: SettingData
    @State var description: String = "Loading..."
    @State private var customImageData: Data? = nil
    @State private var customNSImage: NSImage? = nil
    @State var about: Bool = false
    
    func wallpaperImage(_ wallpaper: Wallpaper) -> some View {
        Image(wallpaper.wallpaperName)
            .resizable()
            .scaledToFill()
            .frame(width: 160, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                data.background == wallpaper.wallpaperName && data.backgroundImageData == nil ?
                RoundedRectangle(cornerRadius: 10, style: .circular)
                    .stroke(.blue, lineWidth: 2) : nil
            )
    }

    // MARK: Photo Thumbnail Builder
    @ViewBuilder
    func customPhotoThumbnail() -> some View {
        if let imageData = data.backgroundImageData, let nsImage = NSImage(data: imageData) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    data.backgroundImageData != nil ?
                    RoundedRectangle(cornerRadius: 10, style: .circular)
                        .stroke(.blue, lineWidth: 2) : nil
                )
        } else {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(width: 160, height: 90)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                )
        }
    }
    
    var fontsview: some View {
        VStack {
            HStack {
                Text("_Fonts_")
                    .font(.custom(data.font.titleFont, size: 20))
                Spacer()
            }
            HStack {
                Text("Title font")
                    .font(.custom(data.font.bodyFont, size: 18))
                Picker("", selection: $data.font.titleFont) {
                    ForEach(availableFonts, id: \.self) { font in
                        Text(font)
                            .font(.custom(font, size: 16))
                            .tag(font)
                            .padding()
                    }
                }
                Spacer()
            }
            
            HStack {
                Text("Body font:")
                    .font(.custom(data.font.bodyFont, size: 18))
                Picker("", selection: $data.font.bodyFont) {
                    ForEach(availableFonts, id: \.self) { font in
                        Text(font)
                            .font(.custom(font, size: 16))
                            .tag(font)
                            .padding()
                    }
                }
                Spacer()
            }
            
            HStack {
                Text("Clock font:")
                    .font(.custom(data.font.bodyFont, size: 18))
                Picker("" ,selection: $data.font.clockFont) {
                    ForEach(availableClockFonts, id: \.self) { font in
                        Text(font)
                            .font(.custom(font, size: 16))
                            .tag(font)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
    
    var timerDurations: some View {
        VStack {
            HStack {
                Text("_Timer Settings_")
                    .font(.custom(data.font.titleFont, size: 20))
                Spacer()
            }
            HStack {
                Text("Pomodoro Timer Duration")
                    .font(.custom(data.font.bodyFont, size: 18))
                Spacer()
                TextField("25", value: $data.pomodoroDuration[0], format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom(data.font.bodyFont, size: 18))
                    .frame(width: 40)
                Text(":")
                    .font(.custom(data.font.bodyFont, size: 18))
                TextField("00", value: $data.pomodoroDuration[1], format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom(data.font.bodyFont, size: 18))
                    .frame(width: 40)
            }
            HStack {
                Text("Short Break Duration")
                    .font(.custom(data.font.bodyFont, size: 18))
                Spacer()
                TextField("5", value: $data.shortBreakDuration[0], format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom(data.font.bodyFont, size: 18))
                    .frame(width: 40)
                Text(":")
                    .font(.custom(data.font.bodyFont, size: 18))
                TextField("00", value: $data.shortBreakDuration[1], format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom(data.font.bodyFont, size: 18))
                    .frame(width: 40)
            }
            HStack {
                Text("Long Break Duration")
                    .font(.custom(data.font.bodyFont, size: 18))
                Spacer()
                TextField("10", value: $data.longBreakDuration[0], format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom(data.font.bodyFont, size: 18))
                    .frame(width: 40)
                Text(":")
                    .font(.custom(data.font.bodyFont, size: 18))
                TextField("00", value: $data.longBreakDuration[1], format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom(data.font.bodyFont, size: 18))
                    .frame(width: 40)
            }
            HStack {
                Text("Cycles before Long Break")
                    .font(.custom(data.font.bodyFont, size: 18))
                Spacer()
                TextField("4", value: $data.cyclesBeforeLongBreak, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom(data.font.bodyFont, size: 18))
                    .frame(width: 100)
            }
//            HStack {
//                Text("Timer chime")
//                    .font(.custom(data.font.bodyFont, size: 18))
//                Spacer()
//                Button {
//                     play(sound: data.notificationSound.fileName)
//                } label: {
//                    Image(systemName: "play.circle")
//                }
//                Picker("", selection: $data.notificationSound) {
//                     ForEach(sounds, id: \.id) { sound in
//                         Text(sound.friendlyName)
//                             .font(.custom(data.font.bodyFont, size: 18))
//                             .tag(sound)
//                     }
//                }
//            }
        }
    }
    
    var wallpaperSettings: some View {
        Group {
            VStack {
                HStack {
                    Text("_Backgrounds_")
                        .font(.custom(data.font.titleFont, size: 20))
                    Spacer()
                }
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(wallpapers, id: \.id) { wallpaper in
                            Button {
                                withAnimation {
                                    data.background = wallpaper.wallpaperName
                                    data.backgroundImageData = nil
                                    description = wallpaper.description
                                }
                            } label: {
                                wallpaperImage(wallpaper)
                            }
                            .buttonStyle(.borderless)
                        }
                        Button {
                            let panel = NSOpenPanel()
                            panel.allowedContentTypes = [.image]
                            panel.allowsMultipleSelection = false
                            if panel.runModal() == .OK, let url = panel.url {
                                if let data = try? Data(contentsOf: url), let nsImage = NSImage(data: data) {
                                    withAnimation {
                                        self.data.backgroundImageData = data
                                        self.data.background = "Custom Photo"
                                        self.description = "A custom photo to match your wonderful personality"
                                        self.customNSImage = nsImage
                                    }
                                }
                            }
                        } label: {
                            customPhotoThumbnail()
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            VStack {
                HStack {
                    Text("_\(data.background)_")
                        .font(.custom(data.font.titleFont, size: 20))
                    Spacer()
                }
                HStack {
                    Text(description)
                        .font(.custom(data.font.bodyFont, size: 18))
                        .onAppear {
                            for wallpaper in wallpapers {
                                if wallpaper.wallpaperName == data.background {
                                    description = wallpaper.description
                                }
                            }
                        }
                    Spacer()
                }
            }
            .transition(.opacity)
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("_Settings_")
                    .font(.custom(data.font.titleFont, size: 36))
                Spacer()
            }
            ScrollView {
                fontsview
                Divider()
                wallpaperSettings
                Divider()
                timerDurations
                Divider()
                
                VStack {
                    HStack {
                        Text("_Extras_")
                            .font(.custom(data.font.titleFont, size: 20))
                        Spacer()
                    }
                    HStack {
                        Button {
                            withAnimation {
                                data.pomodoroDuration = [25, 00]
                                data.shortBreakDuration = [5, 00]
                                data.longBreakDuration = [10, 00]
                                data.font.bodyFont = "Crimson Pro"
                                data.font.titleFont = "Playfair Display"
                                data.font.clockFont = "Crimson Pro"
                                data.background = "Default"
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Reset settings to defaults")
                                    .font(.custom(data.font.bodyFont, size: 18))
                                Spacer()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .padding(25)
    }
}
