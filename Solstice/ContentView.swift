//
//  ContentView.swift
//  Solstice
//
//  Created by Milind Contractor on 28/12/24.
//

import SwiftUI
import Forever

struct ContentView: View {
    @Forever("name") var name: String = ""
    @DontDie("todos") var todos: [Todo] = []

    var body: some View {
        SetupView(name: $name)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
