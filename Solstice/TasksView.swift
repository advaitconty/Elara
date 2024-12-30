//
//  TasksView.swift
//  Solstice
//
//  Created by Milind Contractor on 29/12/24.
//

import SwiftUI

struct TasksView: View {
    @Binding var todos: [Todo]
    @State var shadow = false
    var body: some View {
        VStack {
            HStack {
                Text("_Tasks_")
                    .font(.custom("Playfair Display", size: 36))
                Spacer()
            }
            VStack {
                ForEach($todos) { $todo in
                    HStack {
                        Image(systemName: todo.completed ? "checkmark.circle" : "circle")
                            .font(.system(size: 18))
                            .onTapGesture {
                                todo.completed.toggle()
                            }
                        TextField("Task", text: $todo.task)
                            .font(.custom("Crimson Pro", size: 18))
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
        }
        .padding()
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(todos: .constant([Todo(task: "physics", priority: 1, completed: true), Todo(task: "physics", priority: 1, completed: true), Todo(task: "physics", priority: 1, completed: true)]))
    }
}
