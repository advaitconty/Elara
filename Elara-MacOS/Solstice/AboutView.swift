//
//  AboutView.swift
//  Solstice
//
//  Created by Milind Contractor on 16/1/25.
//

import SwiftUI

struct AboutView: View {
    func updateNotesGenerator(updateName: String, updateCodename: String, features: [String], bugFix: Bool) -> some View {
        VStack {
            HStack {
                Text("\(updateName)")
                    .font(.custom("Playfair Display", size: 20))
                Spacer()
            }
            if !bugFix {
                HStack {
                    Text("_\(updateCodename)_ bring some interesting new features to Elara! Here's what they are:")
                        .font(.custom("Crimson Pro", size: 15))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            } else {
                HStack {
                    Text("This update doesn't really bring much to the table, just some minor bug patches!")
                        .font(.custom("Crimson Pro", size: 15))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            ForEach(features, id: \.self) { feature in
                HStack {
                    Text("- \(feature)")
                        .font(.custom("Crimson Pro", size: 15))
                    Spacer()
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image("solstice")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125)
                    .padding()
                
                VStack {
                    HStack {
                        Text("Elara")
                            .font(.custom("Playfair Display", size: 36))
                            .italic()
                        Spacer()
                    }
                    HStack {
                        Text("_Nebula_ v1.1 (Update Orion)")
                            .font(.custom("Playfair Display", size: 20))
                        Spacer()
                    }
                    HStack {
                        Text("Made with ❤️ by advaitconty")
                            .font(.custom("Crimson Pro", size: 17))
                        Spacer()
                    }
                }
            }
            
            VStack {
                ScrollView {
                    VStack {
                        HStack {
                            Text("_Update Notes_")
                                .font(.custom("Playfair Display", size: 18))
                            Spacer()
                        }
                        HStack {
                            Text("This contains all the changes done in the last few updates")
                                .font(.custom("Crimson Pro", size: 17))
                            Spacer()
                        }
                        Divider()
                        VStack(spacing: 10) {
                            updateNotesGenerator(updateName: "Elara Nebula v1.2 (Update Eclipse)", updateCodename: "Update Eclipse", features: ["NEW: Notifications for when your work is done"], bugFix: false)
                            Divider()
                            updateNotesGenerator(updateName: "Elara Nebula v1.1 (Update Sundial)", updateCodename: "Update Sundial", features: ["NEW: Customisable wallpapers", "IMPROVED: General optimizations to the code", "IMPROVED: Better window resizing"], bugFix: false)
                        }
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.2))
                .frame(minHeight: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10.0))

            }
            
        }
        .frame(width: 525, height: 300)
        .padding()
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
