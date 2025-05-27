//
//  ContentView.swift
//  Solstice
//
//  Created by Milind Contractor on 28/12/24.
//

import SwiftUI
import Forever

struct ContentView: View {
    @Binding var name: String
    @Binding var todos: [Todo]
    @Binding var setupPage: Int
    @Binding var settingsData: SettingData

    var body: some View {
        if setupPage != 3 {
            SetupView(name: $name, todos: $todos, page: $setupPage)
                .transition(.slide)
        } else {
            TimerView(todos: $todos, name: $name, settings: $settingsData)
                .transition(.slide)
        }
    }
}

