import SwiftUI
import PhotosUI

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
    @Environment(\.dismiss) var dismiss
    @State var description: String = "Loading..."
    @State private var selectedItem: PhotosPickerItem?
    @State private var customImageData: Data? = nil
    @State var about: Bool = false
    @Environment(\.openURL) var openURL
    
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
        if let imageData = data.backgroundImageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
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
                Text("_Timer Durations_")
                    .font(.custom(data.font.titleFont, size: 20))
                Spacer()
            }
            HStack {
                Text("Pomodoro Timer Duration")
                    .font(.custom(data.font.bodyFont, size: 18))
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
                Spacer()
            }
            HStack {
                Text("Short Break Duration")
                    .font(.custom(data.font.bodyFont, size: 18))
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
                Spacer()
            }
            HStack {
                Text("Long Break Duration")
                    .font(.custom(data.font.bodyFont, size: 18))
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
                Spacer()
            }
            HStack {
                Text("Cycles before Long Break")
                    .font(.custom(data.font.bodyFont, size: 18))
                TextField("4", value: $data.cyclesBeforeLongBreak, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .font(.custom(data.font.bodyFont, size: 18))
                    .frame(width: 100)
                Spacer()
            }
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
                            .hoverEffect(.automatic)
                        }
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            customPhotoThumbnail()
                        }
                        .hoverEffect(.automatic)
                        .onChange(of: selectedItem) { newItem in
                            if let item = newItem {
                                Task {
                                    do {
                                        if let data = try await item.loadTransferable(type: Data.self) {
                                            withAnimation {
                                                self.data.backgroundImageData = data
                                                self.data.background = "Custom Photo"
                                                self.description = "A custom photo to match your wonderful personality"
                                            }
                                        }
                                    } catch {
                                        print("Error loading photo: \(error)")
                                    }
                                }
                            }
                        }
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
    
    var notificationNotifier: some View {
        HStack {
            Text("Elara does not have access to send notifications")
                .font(.custom(data.font.bodyFont, size: 18))
            Spacer()
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            } label: {
                Text("Give permissions in Settings")
                    .font(.custom(data.font.bodyFont, size: 14))
                    .italic()
            }
            .buttonStyle(.bordered)
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("_Settings_")
                    .font(.custom(data.font.titleFont, size: 36))
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
                .foregroundColor(.gray)
            }
            ScrollView {
                fontsview
                Divider()
                wallpaperSettings
                Divider()
                timerDurations
                Divider()
                if !data.notificationsPermissionsGiven {
                    notificationNotifier
                    Divider()
                }
                
                
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
                        .hoverEffect(.automatic)
                        
                        Button {
                            about = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("About Elara")
                                    .font(.custom(data.font.bodyFont, size: 18))
                                Spacer()
                            }
                        }
                        .buttonStyle(.bordered)
                        .hoverEffect(.automatic)
                    }
                }
            }
        }
        .sheet(isPresented: $about) {
            AboutView()
        }
        .preferredColorScheme(.dark)
        .padding(25)
    }
}
