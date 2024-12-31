//
//  TasksView.swift
//  Solstice
//
//  Created by Milind Contractor on 29/12/24.
//

import SwiftUI

struct DeleteTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var todoToDelete: Todo
    @Binding var todos: [Todo]
    
    var body: some View {
        VStack {
            HStack {
                Text("Are you _sure_?")
                    .font(.custom("Playfair Display", size: 30))
                Spacer()
            }
            HStack {
                Text("Are you sure you want to delete \(todoToDelete.task)?")
                    .font(.custom("Crimson Pro", size: 18))
                Spacer()
            }
            HStack {
                Button {
                    todos.removeAll { $0.id == todoToDelete.id }
                    dismiss()
                } label: {
                    Spacer()
                    Text("Yes")
                        .font(.custom("Crimson Pro", size: 18))
                    Spacer()
                }
                Button {
                    dismiss()
                } label: {
                    Spacer()
                    Text("No")
                        .font(.custom("Crimson Pro", size: 18))
                    Spacer()
                }
            }
        }
        .padding()
        .frame(width: 400, height: 150)
    }
}

struct TasksView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var todos: [Todo]
    @State var addTask: Bool = false
    @State var tasks: String = ""
    
    var task: some View {
        VStack {
            HStack {
                Text("_Add Task_")
                    .font(.custom("Playfair Display", size: 30))
                Spacer()
            }
            
            HStack {
                Text("Task:")
                    .font(.custom("Crimson Pro", size: 18))
                TextField("A. Maths Topical", text: $tasks)
                    .font(.custom("Crimson Pro", size: 18))
            }
            
            Button {
                todos.append(Todo(task: tasks, priority: 4))
                tasks = ""
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                    Text("Add task")
                        .font(.custom("Crimson Pro", size: 18))
                    Spacer()
                }
            }
        }
        .padding()
        .frame(width: 450, height: 200)
    }
    
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
                        Button {
                            todo.completed.toggle()
                        } label: {
                            Image(systemName: todo.completed ? "checkmark.circle" : "circle")
                        }
                        TextField("Task", text: $todo.task)
                            .font(.custom("Crimson Pro", size: 18))
                            .textFieldStyle(.roundedBorder)
                        
                        if todos.count != 1 {
                            Button {
                                todo.showDeletePopup = true
                            } label: {
                                Image(systemName: "trash")
                            }
                            .popover(isPresented: $todo.showDeletePopup) {
                                DeleteTaskView(todoToDelete: $todo, todos: $todos)
                            }
                        }
                    }
                }
                
                HStack {
                    Button {
                        addTask = true
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                            Text("Add task")
                                .font(.custom("Crimson Pro", size: 18))
                            Spacer()
                        }
                        .frame(height: 40)
                    }
                }
                .popover(isPresented: $addTask, arrowEdge: .leading) {
                    task
                }
            }
        }
        .padding()
        .frame(minWidth: 500)
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(todos: .constant([Todo(task: "physics", priority: 1, completed: true), Todo(task: "physics", priority: 1, completed: true), Todo(task: "physics", priority: 1, completed: true)]))
    }
}
