//
//  SetupView.swift
//  Solstice
//
//  Created by Milind Contractor on 28/12/24.
//

import SwiftUI

struct SetupView: View {
    @Binding var name: String
    @Binding var todos: [Todo]
    @State var height = 100
    @State var blur = true
    @State var showName = false
    @Binding var page: Int
    @State var showError = false
    @State var task: String = ""
    
    var body: some View {
        ZStack {
            Image("Default")
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
                                if name == "" {
                                    showError = true
                                } else {
                                    withAnimation {
                                        page = 2
                                    }
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
                        .transition(.opacity)
                        .alert("Your name is blank. Please enter something.", isPresented: $showError) {
                            Button("Okay", role: .cancel) {
                                
                            }
                        }
                        
                    } else if page == 2 {
                        VStack {
                            Text("Hello, _\(name)_!")
                                .font(.custom("Crimson Pro", size: 20))
                            Text("What task would you like to do _today_?")
                                .font(.custom("Crimson Pro", size: 20))
                            HStack {
                                Text("Task:")
                                    .font(.custom("Crimson Pro", size: 20))
                                TextField("Finish studying Physics: Kinematics", text: $task)
                                    .font(.custom("Crimson Pro", size: 20))
                            }
                            HStack {
                                Button {
                                    withAnimation {
                                        page = 1
                                        height = 200
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
                                    if task == "" {
                                        showError = true
                                    } else {
                                        todos.append(Todo(task: task, priority: 1))
                                        todos.append(Todo(task: "", priority: 1))
                                        todos.append(Todo(task: "", priority: 1))
                                        withAnimation {
                                            page = 3
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Finish setup")
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
                        .transition(.opacity)
                        .onAppear {
                            withAnimation {
                                height = 230
                            }
                        }
                        .alert("Your task is blank. Please enter something.", isPresented: $showError) {
                            Button("Okay", role: .cancel) {
                                
                            }
                        }
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
