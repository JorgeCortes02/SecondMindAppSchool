//
//List.swift
//  SecondMind
//
//  Created by Jorge Cortés on 28/7/25.
//
import SwiftUI
struct TaskList: View {
    @Environment(\.modelContext) private var context
    @Bindable var editableProject: Project
    @EnvironmentObject var utilFunctions: generalFunctions

    // computed property en lugar de @State
    private var filteredTasks: [TaskItem] {
        editableProject.tasks
            .filter { $0.status == .on }
            .sorted {
                switch ($0.endDate, $1.endDate) {
                case let (fechaA?, fechaB?): return fechaA < fechaB
                case (_?, nil): return true
                case (nil, _?): return false
                case (nil, nil): return false
                }
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tareas del proyecto")
                    .font(.headline)
                    .foregroundColor(Color.taskButtonColor)
                Text("\(filteredTasks.count)").bold()
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Ver más")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(Color.taskButtonColor)
                }
            }

            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)

            if filteredTasks.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.text.page")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 90)
                        .foregroundColor(Color.taskButtonColor.opacity(0.7))

                    Text("No hay tareas disponibles.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .padding(20)
            } else if filteredTasks.count == 1 {
                ForEach(filteredTasks.prefix(1)) { task in
                    NavigationLink(destination: TaskDetall(editableTask: task)) {
                        taskRow(task: task)
                    }
                
                }
            } else {
                ForEach(filteredTasks.prefix(2)) { task in
                    NavigationLink(destination: TaskDetall(editableTask: task)) {
                        taskRow(task: task)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.cardBackground)
    }

    private func taskRow(task: TaskItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 22))
                .foregroundColor(Color.taskButtonColor)

            Text(task.title)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)

            Spacer()

            Button {
                deleteTask(task)
            } label: {
                Image(systemName: "circle")
                    .font(.system(size: 21))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .modifier(TaskCardModifier())
    }

    private func deleteTask(_ task: TaskItem) {
        task.status = .off
        task.completeDate = Date()
        do {
            try context.save()
        } catch {
            print("Error al guardar cambios: \(error)")
        }
    }
}
