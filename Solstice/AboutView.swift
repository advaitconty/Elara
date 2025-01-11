//
//  AboutView.swift
//  Solstice
//
//  Created by Milind Contractor on 30/12/24.
//

import SwiftUI

struct AboutView: View {
    func updateNotesGenerator(updateName: String, updateCodename: String, features: [String], bugFix: Bool) -> some View {
        VStack {
            HStack {
                Text("Solstice Nebula v1.2 _Update Eclipse_")
                    .font(.custom("Playfair Display", size: 20))
                Spacer()
            }
            if !bugFix {
                HStack {
                    Text("_\(updateCodename)_ bring some interesting new features to Solstice! Here's what they are:")
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
                        Text("Solstice")
                            .font(.custom("Playfair Display", size: 36))
                            .italic()
                        Spacer()
                    }
                    HStack {
                        Text("_Nebula_ v1.2")
                            .font(.custom("Playfair Display", size: 20))
                        Spacer()
                    }
                    HStack {
                        Text("_Update Eclipse_")
                            .font(.custom("Playfair Display", size: 20))
                        Spacer()
                    }
                    .padding(.bottom)
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
                            Text("This contains all the changes done in the last 3 updates")
                                .font(.custom("Crimson Pro", size: 17))
                            Spacer()
                        }
                        Divider()
                        VStack(spacing: 10) {
                            updateNotesGenerator(updateName: "Solstice Nebula v1.2 _Update Eclipse_", updateCodename: "Update Eclipse", features: ["NEW: Clock mode", "NEW: Custom fonts (available in settings)", "NEW: Reset switch"], bugFix: false)
                                                        
                            updateNotesGenerator(updateName: "Solstice Nebula v1.1.1 _Update Orion_", updateCodename: "Update Orion", features: [], bugFix: true)
                                                        
                            updateNotesGenerator(updateName: "Solstice Nebula v1.1 _Update Orion_", updateCodename: "Update Orion", features: ["UPGRADE: Infinite task lists"], bugFix: false)
                        }
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.2))
                .frame(minHeight: 100)

            }
            
            Text("This app will soon be on the App Store, please stay tuned!")
                .font(.custom("Crimson Pro", size: 17))
            
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
