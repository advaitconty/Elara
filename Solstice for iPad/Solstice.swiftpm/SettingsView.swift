let availableClockFonts = ["Playfair Display", "London Underground LCD Clock", "Crimson Pro", "Chakra Petch", "Share Tech Mono", "Helvetica Neue", "Avenir Next", "Doto", "Space Grotesk", "Playwrite AU SA", "Public Sans"]
let availableFonts = ["Playfair Display", "Crimson Pro", "Chakra Petch", "Share Tech Mono", "Helvetica Neue", "Avenir Next", "Space Grotesk", "Playwrite Australia SA", "Public Sans"]


import SwiftUI

struct SettingsView: View {
    @Binding var data: SettingData
    @Environment(\.dismiss) var dismiss
    @State var description: String = "Loading..."
    @State var showAbout = false
    
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
            // Wallpaper
            ScrollView {
                Group {
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
                    Divider()
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
                                            for wallpaper in wallpapers {
                                                if wallpaper.wallpaperName == data.background {
                                                    description = wallpaper.description
                                                }
                                            }
                                        }
                                    } label: {
                                        if data.background == wallpaper.wallpaperName {
                                            Image(wallpaper.wallpaperName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 160, height: 90)
                                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10, style: .circular)
                                                        .stroke(.blue, lineWidth: 2)
                                                )
                                        } else {
                                            Image(wallpaper.wallpaperName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 160, height: 90)
                                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                        }
                                    }
                                    .buttonStyle(.borderless)
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
                Divider()
                // Others
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
                Divider()
                
                VStack {
                    HStack {
                        Text("_The Danger Zone_")
                            .font(.custom(data.font.titleFont, size: 20))
                        Spacer()
                    }
                    VStack {
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
                    
                    VStack {
                        HStack {
                            Text("_About_")
                                .font(.custom(data.font.titleFont, size: 20))
                            Spacer()
                        }
                        VStack {
                            Button {
                                showAbout = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "info.circle")
                                    Text("About _Solstice_")
                                        .font(.custom(data.font.bodyFont, size: 18))
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .sheet(isPresented: $showAbout) {
                            AboutView()
                        }
                    }

                }
            }
        }
        .preferredColorScheme(.dark)
        .padding(25)
    }
}
