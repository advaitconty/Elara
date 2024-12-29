//
//  SetupView.swift
//  Solstice
//
//  Created by Milind Contractor on 28/12/24.
//

import SwiftUI

struct SetupView: View {
    @Binding var name: String
    @State var height = 100
    @State var blur = true
    @State var showName = false
    @State var page = 1
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(width: 1600, height: 1000)
                .blur(radius: blur ? 20.0 : 0.0)
            VStack {
                Text("Welcome to _Solstice_")
                    .font(.custom("Playfair Display", size: 36))
                    .foregroundColor(.white)
                
                Text("Your _ultimate_ time tracker")
                    .font(.custom("Crimson Pro", size: 20))
                    .foregroundColor(.white)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                blur = false
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                height = 200
                                showName = true
                            }
                        }
                    }
                
                if showName {
                    if page == 1 {
                        VStack {
                            HStack {
                                Text("Name:")
                                    .font(.custom("Crimson Pro", size: 20))
                                TextField("Advait", text: $name)
                                    .font(.custom("Crimson Pro", size: 20))
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            Button {
                                withAnimation {
                                    page = 2
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Continue")
                                        .font(.custom("Crimson Pro", size: 20))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                        .fill(Color.gray)
                                        .opacity(0.5)
                                        .blendMode(.overlay)
                                        .shadow(radius: 3)
                                }
                            }
                            .padding()
                            .buttonStyle(.borderless)
                        }
                        .transition(.scale)
                    } else if page == 2 {
                        VStack {
                            HStack {
                                Button {
                                    withAnimation {
                                        page = 1
                                    }
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Back")
                                            .font(.custom("Crimson Pro", size: 20))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .background {
                                        RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                            .fill(Color.gray)
                                            .opacity(0.5)
                                            .blendMode(.overlay)
                                            .shadow(radius: 3)
                                    }
                                }
                                .padding()
                                .buttonStyle(.borderless)
                                Button {
                                    withAnimation {
                                        page = 2
                                    }
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Continue")
                                            .font(.custom("Crimson Pro", size: 20))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .background {
                                        RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                            .fill(Color.gray)
                                            .opacity(0.5)
                                            .blendMode(.overlay)
                                            .shadow(radius: 3)
                                    }
                                }
                                .padding()
                                .buttonStyle(.borderless)
                            }
                        }
                        .transition(.scale)
                    }
                }
            }
            .padding()
            .frame(width: 400, height: CGFloat(height))
            .background {
                RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                                .fill(Color.black)
                                .opacity(0.7)
                                .blendMode(.overlay)
                                .shadow(radius: 3)
            }
        }
        .padding()
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView(name: .constant("Advait"))
    }
}
